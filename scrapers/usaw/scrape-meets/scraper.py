"""USAW Meet Scraper - Scrapes meets from USAW Sport80 and adds them to Notion"""
import os
import re
import json
import base64
import urllib.parse
import logging
from datetime import datetime, timezone, timedelta
from dotenv import load_dotenv
from notion_client import Client
from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeout

# Load environment variables
load_dotenv(dotenv_path="../../.env")

# Configuration
USAW_WIDGET_URL = "https://usaweightlifting.sport80.com/public/widget/1"
NOTION_SECRET = os.environ.get("NOTION_SECRET")
NOTION_DATABASE_ID = os.environ.get("NOTION_DATABASE_ID")

# Logging setup
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler()],
)


class NotionMeetManager:
    """Manages meet data in Notion database"""

    def __init__(self, api_key: str, database_id: str):
        self.client = Client(auth=api_key)
        self.database_id = database_id

    def get_existing_meet_names(self):
        """Fetch all existing meet names from Notion to avoid duplicates"""
        existing_meets = set()

        try:
            has_more = True
            start_cursor = None

            while has_more:
                # Format database ID with hyphens if needed
                db_id = self.database_id
                if len(db_id) == 32 and '-' not in db_id:
                    db_id = f"{db_id[0:8]}-{db_id[8:12]}-{db_id[12:16]}-{db_id[16:20]}-{db_id[20:32]}"

                payload = {"page_size": 100}
                if start_cursor:
                    payload["start_cursor"] = start_cursor

                response = self.client.request(
                    method="POST",
                    path=f"databases/{db_id}/query",
                    body=payload
                )

                for page in response.get("results", []):
                    # Extract meet name from properties
                    meet_name_prop = page.get("properties", {}).get("Meet Name", {})
                    if meet_name_prop.get("title") and len(meet_name_prop["title"]) > 0:
                        meet_name = meet_name_prop["title"][0]["plain_text"]
                        existing_meets.add(meet_name)

                has_more = response.get("has_more", False)
                start_cursor = response.get("next_cursor")

            logging.info(f"Found {len(existing_meets)} existing meets in Notion")
            return existing_meets

        except Exception as e:
            logging.warning(f"Could not fetch existing meets from Notion: {e}")
            return set()

    def add_meet_to_notion(self, meet_data: dict):
        """
        Add a meet to the Notion database
        :param meet_data: Dictionary with meet information
        """
        try:
            properties = {
                "Meet Name": {
                    "title": [
                        {
                            "text": {
                                "content": meet_data.get("meet_name", "Unknown Meet")
                            }
                        }
                    ]
                }
            }

            # Add organizer name if available
            if meet_data.get("organizer_name"):
                properties["Organizer Name"] = {
                    "rich_text": [
                        {
                            "text": {
                                "content": meet_data["organizer_name"]
                            }
                        }
                    ]
                }

            # Add organizer email if available
            if meet_data.get("organizer_email"):
                properties["Organizer Email"] = {
                    "email": meet_data["organizer_email"]
                }

            # Add meet date if available
            if meet_data.get("meet_date"):
                properties["Meet Date"] = {
                    "date": {
                        "start": meet_data["meet_date"]
                    }
                }

            # Add Emailed? property with default value "No"
            properties["Emailed?"] = {
                "select": {
                    "name": "No"
                }
            }

            self.client.pages.create(
                parent={"database_id": self.database_id},
                properties=properties
            )

            logging.info(f"Successfully added meet: {meet_data.get('meet_name')}")
            return True

        except Exception as e:
            logging.error(f"Error adding meet to Notion: {e}")
            return False


def scrape_meets_with_playwright():
    """Scrape meets from USAW using Playwright"""
    logging.info("Launching browser...")

    meets = []

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(
            viewport={'width': 1920, 'height': 1080},
            user_agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        )
        page = context.new_page()

        try:
            # Calculate date range (today to 2 months from now)
            today = datetime.now(timezone.utc)
            two_months = today + timedelta(days=60)

            from_date = today.strftime("%Y-%m-%d")
            to_date = two_months.strftime("%Y-%m-%d")

            # Build filter JSON and encode it properly
            filter_dict = {"event_from_date": from_date, "event_to_date": to_date}
            filter_json = json.dumps(filter_dict, separators=(',', ':'))
            filter_b64 = base64.b64encode(filter_json.encode()).decode()

            # Use the exact widget URL format
            url = f"https://usaweightlifting.sport80.com/public/widget/1?filters={urllib.parse.quote(filter_b64, safe='')}"

            logging.info(f"Navigating to widget page for {from_date} to {to_date}...")
            logging.info(f"URL: {url}")
            page.goto(url, wait_until='networkidle', timeout=30000)

            # Wait for Vue app to render and load data
            page.wait_for_timeout(8000)

            # Look for Enter Now buttons by finding spans with "Enter Now" text, then get parent button
            all_spans = page.query_selector_all('span')

            enter_buttons = []
            for span in all_spans:
                try:
                    span_text = span.inner_text().strip()
                    if span_text == 'Enter Now':
                        # Get the parent button
                        button = span.evaluate_handle('el => el.closest("button")')
                        if button:
                            enter_buttons.append(button.as_element())
                except:
                    continue

            logging.info(f"Found {len(enter_buttons)} 'Enter Now' buttons on the page")

            # First, collect basic meet info without navigating
            meets_basic_info = []
            for i, enter_button in enumerate(enter_buttons):
                try:
                    # Extract meet name and date from the parent container
                    parent_text = enter_button.evaluate('el => el.parentElement.parentElement.innerText')
                    lines = parent_text.split('\n')

                    # First line is usually the meet name
                    meet_name = lines[0].strip() if lines else ""

                    # Filter out invalid meet names
                    invalid_names = ['select filters', 'filters', '1', '2', '3', 'login', 'enter now']
                    if not meet_name or meet_name.lower() in invalid_names or len(meet_name) < 5:
                        logging.info(f"Skipping invalid meet name: {meet_name}")
                        continue

                    # Extract date - usually in next few lines
                    meet_date = None
                    for line in lines[1:4]:
                        if '/' in line and '-' in line:
                            # Format: "MM/DD/YYYY - MM/DD/YYYY"
                            try:
                                start_date_str = line.split("-")[0].strip()
                                meet_date = datetime.strptime(start_date_str, "%m/%d/%Y").strftime("%Y-%m-%d")
                                break
                            except:
                                pass

                    meets_basic_info.append({
                        "meet_name": meet_name,
                        "meet_date": meet_date
                    })
                    logging.info(f"Found: {meet_name} ({meet_date or 'No date'})")

                except Exception as e:
                    logging.error(f"Error scraping meet {i}: {e}")
                    continue

            logging.info(f"Collected {len(meets_basic_info)} meets. Scraping organizer info...")

            # Try to get event IDs from the page data
            # Sport80 stores event data in JavaScript variables or data attributes
            event_data = page.evaluate('''() => {
                // Try to find event data in Vue app state or window object
                if (window.__NUXT__) return window.__NUXT__;
                if (window.__INITIAL_STATE__) return window.__INITIAL_STATE__;

                // Try to extract event IDs from the DOM
                const events = [];
                document.querySelectorAll('button.s80-btn').forEach(btn => {
                    const parent = btn.closest('[data-event-id]') || btn.closest('div');
                    const text = parent?.innerText || '';
                    events.push({
                        text: text.split('\\n')[0],
                        html: parent?.outerHTML?.substring(0, 500) || ''
                    });
                });
                return events;
            }''')

            logging.info(f"Event data from page: {json.dumps(event_data, indent=2)[:1000]}")

            # Now scrape organizer info by visiting each meet detail page
            for idx, basic_info in enumerate(meets_basic_info):
                meet_name = basic_info["meet_name"]
                meet_date = basic_info["meet_date"]

                organizer_name = None
                organizer_email = None

                # Try to navigate to the detail page using the button
                try:
                    # Re-query for the button (in case page changed)
                    buttons = page.query_selector_all('button.s80-btn')
                    for btn in buttons:
                        try:
                            btn_parent_text = btn.evaluate('el => el.parentElement.parentElement.innerText')
                            if meet_name in btn_parent_text:
                                logging.info(f"Clicking button for: {meet_name}")

                                # Click and wait for navigation
                                btn.click()
                                page.wait_for_load_state('domcontentloaded', timeout=10000)
                                page.wait_for_timeout(3000)

                                # Extract organizer info
                                page_content = page.content()

                                # Look for email
                                email_match = re.search(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', page_content)
                                if email_match:
                                    organizer_email = email_match.group(0)
                                    logging.info(f"Found email: {organizer_email}")

                                # Look for organizer name
                                page_text = page.inner_text('body')
                                lines = page_text.split('\n')

                                for i, line in enumerate(lines):
                                    if 'contact' in line.lower() or 'organizer' in line.lower() or 'meet director' in line.lower():
                                        for name_line in lines[i+1:i+4]:
                                            name_line = name_line.strip()
                                            if name_line and '@' not in name_line and len(name_line) > 3:
                                                skip_words = ['email', 'phone', 'address', 'location', 'venue', 'contact', 'name', 'information']
                                                if not any(word in name_line.lower() for word in skip_words):
                                                    organizer_name = name_line
                                                    logging.info(f"Found organizer: {organizer_name}")
                                                    break
                                        if organizer_name:
                                            break

                                # Go back to the list page
                                page.go_back()
                                page.wait_for_load_state('domcontentloaded', timeout=10000)
                                page.wait_for_timeout(2000)
                                break
                        except:
                            continue

                except Exception as e:
                    logging.warning(f"Error getting organizer for {meet_name}: {e}")

                meets.append({
                    "meet_name": meet_name,
                    "meet_date": meet_date,
                    "organizer_name": organizer_name,
                    "organizer_email": organizer_email
                })

                logging.info(f"Scraped: {meet_name} (Email: {organizer_email or 'None'}, Org: {organizer_name or 'None'})")

        except PlaywrightTimeout:
            logging.error("Timeout waiting for page to load")
        except Exception as e:
            logging.error(f"Error during scraping: {e}")
        finally:
            context.close()
            browser.close()

    return meets


def main():
    """Main function to scrape USAW meets and add to Notion"""
    logging.info("Starting USAW meet scraper...")

    if not NOTION_SECRET or not NOTION_DATABASE_ID:
        logging.critical("NOTION_SECRET and NOTION_DATABASE_ID must be set. Exiting.")
        return

    # Initialize Notion manager
    notion_manager = NotionMeetManager(api_key=NOTION_SECRET, database_id=NOTION_DATABASE_ID)

    # Get existing meets from Notion
    existing_meets = notion_manager.get_existing_meet_names()

    # Scrape meets using Playwright
    meets = scrape_meets_with_playwright()

    if not meets:
        logging.info("No meets found. Exiting.")
        return

    # Process each meet
    new_meets_added = 0
    for meet_info in meets:
        meet_name = meet_info.get("meet_name", "")

        # Skip if already exists
        if meet_name in existing_meets:
            logging.info(f"Meet already exists: {meet_name}")
            continue

        # Add to Notion
        if notion_manager.add_meet_to_notion(meet_info):
            new_meets_added += 1
            existing_meets.add(meet_name)  # Add to set to prevent duplicates in this run

    logging.info(f"Finished! Added {new_meets_added} new meets to Notion.")


if __name__ == "__main__":
    main()
