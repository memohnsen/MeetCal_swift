//
//  Supabase.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/7/25.
//


import Foundation
import Supabase
import Clerk

let supabaseURL = "https://ztziuiiharxtvzitwzfv.supabase.co"
let supabaseKey = "sb_publishable_SQ-w0vWM9q3r5eF6PCAFCQ_e12p8AmT"

let supabase = SupabaseClient(
  supabaseURL: URL(string: supabaseURL)!,
  supabaseKey: supabaseKey
)

func getSupabaseClient() -> SupabaseClient {
    return SupabaseClient(
        supabaseURL: URL(string: supabaseURL)!,
        supabaseKey: supabaseKey
    )
}
