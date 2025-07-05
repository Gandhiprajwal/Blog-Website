/*
  # Initial Schema for ROBOSTAAN

  1. New Tables
    - `blogs`
      - `id` (uuid, primary key)
      - `title` (text)
      - `content` (text, rich HTML content)
      - `snippet` (text, short description)
      - `image` (text, image URL)
      - `tags` (text array)
      - `author` (text)
      - `featured` (boolean)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `courses`
      - `id` (uuid, primary key)
      - `title` (text)
      - `description` (text)
      - `content` (text, rich HTML content)
      - `image` (text, image URL)
      - `duration` (text)
      - `category` (text)
      - `video_url` (text, optional)
      - `materials` (text array, optional)
      - `featured` (boolean)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on both tables
    - Add policies for public read access
    - Add policies for authenticated admin access
*/

-- Create blogs table
CREATE TABLE IF NOT EXISTS blogs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  content text NOT NULL,
  snippet text NOT NULL,
  image text NOT NULL,
  tags text[] DEFAULT '{}',
  author text NOT NULL,
  featured boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create courses table
CREATE TABLE IF NOT EXISTS courses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  content text DEFAULT '',
  image text NOT NULL,
  duration text NOT NULL,
  category text NOT NULL CHECK (category IN ('Beginner', 'Intermediate', 'Advanced')),
  video_url text,
  materials text[] DEFAULT '{}',
  featured boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE blogs ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;

-- Create policies for blogs
CREATE POLICY "Blogs are viewable by everyone"
  ON blogs
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert blogs"
  ON blogs
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update blogs"
  ON blogs
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete blogs"
  ON blogs
  FOR DELETE
  TO authenticated
  USING (true);

-- Create policies for courses
CREATE POLICY "Courses are viewable by everyone"
  ON courses
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert courses"
  ON courses
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update courses"
  ON courses
  FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can delete courses"
  ON courses
  FOR DELETE
  TO authenticated
  USING (true);

-- Insert sample blog data
INSERT INTO blogs (title, content, snippet, image, tags, author, featured) VALUES
(
  'Getting Started with Robotics Programming',
  '<h2>Introduction to Robotics Programming</h2><p>Robotics programming is an exciting field that combines hardware and software to create intelligent machines. In this comprehensive guide, we''ll explore the fundamental concepts you need to know to start your journey in robotics programming.</p><h3>What is Robotics Programming?</h3><p>Robotics programming involves writing code that controls robotic systems. This includes:</p><ul><li>Sensor data processing</li><li>Motor control algorithms</li><li>Decision-making logic</li><li>Communication protocols</li></ul><h3>Popular Programming Languages</h3><p>Several programming languages are commonly used in robotics:</p><ol><li><strong>Python</strong> - Great for beginners, extensive libraries</li><li><strong>C++</strong> - High performance, real-time applications</li><li><strong>ROS (Robot Operating System)</strong> - Framework for robot software development</li></ol><p>Let''s dive deeper into each of these technologies and see how they can help you build amazing robotic systems.</p>',
  'Discover the essential concepts and tools needed to begin your journey in robotics programming.',
  'https://images.pexels.com/photos/2085831/pexels-photo-2085831.jpeg?auto=compress&cs=tinysrgb&w=800',
  ARRAY['Programming', 'Python', 'ROS', 'Beginner'],
  'Dr. Sarah Johnson',
  true
),
(
  'Advanced Sensor Integration in Robotics',
  '<h2>Mastering Sensor Integration</h2><p>Sensors are the eyes and ears of robotic systems. Understanding how to integrate and process sensor data is crucial for creating intelligent robots that can interact with their environment.</p><h3>Types of Sensors</h3><p>Modern robots use various types of sensors:</p><ul><li><strong>Vision Sensors</strong> - Cameras, depth sensors, LiDAR</li><li><strong>Motion Sensors</strong> - IMUs, encoders, gyroscopes</li><li><strong>Environmental Sensors</strong> - Temperature, humidity, gas sensors</li><li><strong>Proximity Sensors</strong> - Ultrasonic, infrared, capacitive</li></ul><h3>Sensor Fusion Techniques</h3><p>Combining data from multiple sensors provides more accurate and reliable information:</p><ol><li>Kalman Filtering</li><li>Particle Filtering</li><li>Complementary Filtering</li></ol><p>These techniques help reduce noise and improve the overall performance of your robotic system.</p>',
  'Master the art of sensor fusion and integration for creating intelligent robotic systems.',
  'https://images.pexels.com/photos/2085831/pexels-photo-2085831.jpeg?auto=compress&cs=tinysrgb&w=800',
  ARRAY['Sensors', 'Hardware', 'Advanced'],
  'Prof. Michael Chen',
  false
),
(
  'Machine Learning for Autonomous Navigation',
  '<h2>AI-Powered Robot Navigation</h2><p>Machine learning has revolutionized how robots navigate and interact with their environment. This article explores cutting-edge techniques for autonomous navigation.</p><h3>Navigation Challenges</h3><p>Autonomous navigation involves solving several complex problems:</p><ul><li>Path planning and obstacle avoidance</li><li>Localization and mapping (SLAM)</li><li>Dynamic environment adaptation</li><li>Real-time decision making</li></ul><h3>ML Approaches</h3><p>Various machine learning techniques are used in navigation:</p><ol><li><strong>Reinforcement Learning</strong> - Learning through trial and error</li><li><strong>Deep Learning</strong> - Neural networks for perception</li><li><strong>Computer Vision</strong> - Visual understanding of environment</li></ol><h3>Implementation Example</h3><p>Here''s a simple example of how you might implement a basic navigation algorithm:</p><pre><code>import numpy as np
from sklearn.neural_network import MLPRegressor

class NavigationAgent:
    def __init__(self):
        self.model = MLPRegressor(hidden_layer_sizes=(100, 50))
    
    def train(self, sensor_data, actions):
        self.model.fit(sensor_data, actions)
    
    def predict_action(self, current_sensors):
        return self.model.predict([current_sensors])[0]</code></pre><p>This demonstrates how machine learning can be integrated into robotic navigation systems.</p>',
  'Learn how to use AI and ML techniques to create self-navigating robots.',
  'https://images.pexels.com/photos/2085831/pexels-photo-2085831.jpeg?auto=compress&cs=tinysrgb&w=800',
  ARRAY['AI', 'Machine Learning', 'Navigation'],
  'Dr. Emily Rodriguez',
  true
);

-- Insert sample course data
INSERT INTO courses (title, description, content, image, duration, category, video_url, materials, featured) VALUES
(
  'Introduction to Robotics',
  'A comprehensive introduction to the world of robotics, covering basic concepts, history, and applications.',
  '<h2>Course Overview</h2><p>Welcome to Introduction to Robotics! This course is designed for beginners who want to understand the fundamentals of robotics.</p><h3>What You''ll Learn</h3><ul><li>History and evolution of robotics</li><li>Basic mechanical components</li><li>Introduction to programming robots</li><li>Safety considerations</li><li>Real-world applications</li></ul><h3>Course Structure</h3><p>The course is divided into 8 weekly modules:</p><ol><li>Week 1: Introduction and History</li><li>Week 2: Mechanical Systems</li><li>Week 3: Sensors and Actuators</li><li>Week 4: Basic Programming</li><li>Week 5: Control Systems</li><li>Week 6: Navigation Basics</li><li>Week 7: Human-Robot Interaction</li><li>Week 8: Final Project</li></ol>',
  'https://images.pexels.com/photos/2085831/pexels-photo-2085831.jpeg?auto=compress&cs=tinysrgb&w=800',
  '8 weeks',
  'Beginner',
  'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  ARRAY['Course Handbook PDF', 'Arduino Starter Kit', 'Programming Exercises'],
  true
),
(
  'Advanced Robot Programming',
  'Deep dive into advanced programming techniques for robotics using Python, C++, and ROS.',
  '<h2>Advanced Programming Concepts</h2><p>This advanced course covers sophisticated programming techniques used in modern robotics.</p><h3>Prerequisites</h3><ul><li>Basic programming knowledge</li><li>Understanding of robotics fundamentals</li><li>Familiarity with Linux/Unix systems</li></ul><h3>Technologies Covered</h3><ul><li>ROS (Robot Operating System)</li><li>OpenCV for computer vision</li><li>TensorFlow for machine learning</li><li>Real-time programming concepts</li></ul>',
  'https://images.pexels.com/photos/2085831/pexels-photo-2085831.jpeg?auto=compress&cs=tinysrgb&w=800',
  '12 weeks',
  'Advanced',
  'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  ARRAY['ROS Installation Guide', 'Code Examples Repository', 'Virtual Machine Image'],
  false
),
(
  'Mechatronics Fundamentals',
  'Learn the integration of mechanical, electrical, and software engineering in robotic systems.',
  '<h2>Mechatronics Integration</h2><p>Mechatronics combines mechanical engineering, electronics, and software to create intelligent systems.</p><h3>Core Topics</h3><ul><li>Mechanical design principles</li><li>Electronic circuit design</li><li>Microcontroller programming</li><li>System integration</li></ul>',
  'https://images.pexels.com/photos/2085831/pexels-photo-2085831.jpeg?auto=compress&cs=tinysrgb&w=800',
  '10 weeks',
  'Intermediate',
  'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  ARRAY['Circuit Design Software', 'Component List', 'Lab Manual'],
  true
);