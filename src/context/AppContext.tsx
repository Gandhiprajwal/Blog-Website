import React, { createContext, useContext, useState, useEffect } from 'react';
import { supabase, Blog, Course } from '../lib/supabase';
import { useAuth } from '../components/Auth/AuthProvider';

interface AppContextType {
  blogs: Blog[];
  courses: Course[];
  darkMode: boolean;
  loading: boolean;
  isAdmin: boolean;
  isInstructor: boolean;
  addBlog: (blog: Omit<Blog, 'id' | 'created_at' | 'updated_at'>) => Promise<void>;
  updateBlog: (id: string, blog: Partial<Blog>) => Promise<void>;
  deleteBlog: (id: string) => Promise<void>;
  addCourse: (course: Omit<Course, 'id' | 'created_at' | 'updated_at'>) => Promise<void>;
  updateCourse: (id: string, course: Partial<Course>) => Promise<void>;
  deleteCourse: (id: string) => Promise<void>;
  toggleDarkMode: () => void;
  refreshData: () => Promise<void>;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [blogs, setBlogs] = useState<Blog[]>([]);
  const [courses, setCourses] = useState<Course[]>([]);
  const [darkMode, setDarkMode] = useState(false);
  const [loading, setLoading] = useState(true);
  const { isAdmin, isInstructor } = useAuth();

  useEffect(() => {
    const savedDarkMode = localStorage.getItem('darkMode');
    if (savedDarkMode) {
      setDarkMode(JSON.parse(savedDarkMode));
    }

    fetchData();
  }, []);

  useEffect(() => {
    localStorage.setItem('darkMode', JSON.stringify(darkMode));
    if (darkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [darkMode]);

  const fetchData = async () => {
    try {
      setLoading(true);
      
      // Fetch blogs
      const { data: blogsData, error: blogsError } = await supabase
        .from('blogs')
        .select('*')
        .order('created_at', { ascending: false });

      if (blogsError) throw blogsError;

      // Fetch courses
      const { data: coursesData, error: coursesError } = await supabase
        .from('courses')
        .select('*')
        .order('created_at', { ascending: false });

      if (coursesError) throw coursesError;

      setBlogs(blogsData || []);
      setCourses(coursesData || []);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setLoading(false);
    }
  };

  const refreshData = async () => {
    await fetchData();
  };

  const addBlog = async (blog: Omit<Blog, 'id' | 'created_at' | 'updated_at'>) => {
    try {
      const { data, error } = await supabase
        .from('blogs')
        .insert([blog])
        .select()
        .single();

      if (error) throw error;
      setBlogs(prev => [data, ...prev]);
    } catch (error) {
      console.error('Error adding blog:', error);
      throw error;
    }
  };

  const updateBlog = async (id: string, updatedBlog: Partial<Blog>) => {
    try {
      const { data, error } = await supabase
        .from('blogs')
        .update({ ...updatedBlog, updated_at: new Date().toISOString() })
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;
      setBlogs(prev => prev.map(blog => blog.id === id ? data : blog));
    } catch (error) {
      console.error('Error updating blog:', error);
      throw error;
    }
  };

  const deleteBlog = async (id: string) => {
    try {
      const { error } = await supabase
        .from('blogs')
        .delete()
        .eq('id', id);

      if (error) throw error;
      setBlogs(prev => prev.filter(blog => blog.id !== id));
    } catch (error) {
      console.error('Error deleting blog:', error);
      throw error;
    }
  };

  const addCourse = async (course: Omit<Course, 'id' | 'created_at' | 'updated_at'>) => {
    try {
      const { data, error } = await supabase
        .from('courses')
        .insert([course])
        .select()
        .single();

      if (error) throw error;
      setCourses(prev => [data, ...prev]);
    } catch (error) {
      console.error('Error adding course:', error);
      throw error;
    }
  };

  const updateCourse = async (id: string, updatedCourse: Partial<Course>) => {
    try {
      const { data, error } = await supabase
        .from('courses')
        .update({ ...updatedCourse, updated_at: new Date().toISOString() })
        .eq('id', id)
        .select()
        .single();

      if (error) throw error;
      setCourses(prev => prev.map(course => course.id === id ? data : course));
    } catch (error) {
      console.error('Error updating course:', error);
      throw error;
    }
  };

  const deleteCourse = async (id: string) => {
    try {
      const { error } = await supabase
        .from('courses')
        .delete()
        .eq('id', id);

      if (error) throw error;
      setCourses(prev => prev.filter(course => course.id !== id));
    } catch (error) {
      console.error('Error deleting course:', error);
      throw error;
    }
  };

  const toggleDarkMode = () => {
    setDarkMode(!darkMode);
  };

  const value: AppContextType = {
    blogs,
    courses,
    darkMode,
    loading,
    isAdmin,
    isInstructor,
    addBlog,
    updateBlog,
    deleteBlog,
    addCourse,
    updateCourse,
    deleteCourse,
    toggleDarkMode,
    refreshData
  };

  return (
    <AppContext.Provider value={value}>
      {children}
    </AppContext.Provider>
  );
};