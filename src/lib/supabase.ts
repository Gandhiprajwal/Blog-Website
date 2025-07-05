import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || "https://juoyqkqmzshnidszqlaz.supabase.co";
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp1b3lxa3FtenNobmlkc3pxbGF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3MzA4NzIsImV4cCI6MjA2NzMwNjg3Mn0.VG-4d_ComdJgCvAB6gTumtMgSUuOisFiyBDgHaV6W0M";

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export interface Blog {
  id: string;
  title: string;
  content: string;
  snippet: string;
  image: string;
  tags: string[];
  author: string;
  featured: boolean;
  created_at: string;
  updated_at: string;
}

export interface Course {
  id: string;
  title: string;
  description: string;
  content: string;
  image: string;
  duration: string;
  category: 'Beginner' | 'Intermediate' | 'Advanced';
  video_url?: string;
  materials?: string[];
  featured: boolean;
  created_at: string;
  updated_at: string;
}