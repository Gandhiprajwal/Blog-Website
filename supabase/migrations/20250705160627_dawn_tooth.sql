/*
  # Authentication and User Management

  1. New Tables
    - `user_profiles` - Extended user information
    - `user_preferences` - User settings and preferences
    - `course_enrollments` - Track user course enrollments
    - `blog_likes` - Track user blog likes
    - `comments` - User comments on blogs and courses

  2. Security
    - Enable RLS on all new tables
    - Add policies for authenticated users
    - Create admin role management

  3. Sample Data
    - Add dummy admin users
    - Add more comprehensive blog and course content
*/

-- Create user profiles table
CREATE TABLE IF NOT EXISTS user_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  full_name text,
  avatar_url text,
  bio text,
  role text DEFAULT 'user' CHECK (role IN ('user', 'admin', 'instructor')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create user preferences table
CREATE TABLE IF NOT EXISTS user_preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  dark_mode boolean DEFAULT false,
  email_notifications boolean DEFAULT true,
  course_notifications boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create course enrollments table
CREATE TABLE IF NOT EXISTS course_enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  enrolled_at timestamptz DEFAULT now(),
  progress integer DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
  completed_at timestamptz,
  UNIQUE(user_id, course_id)
);

-- Create blog likes table
CREATE TABLE IF NOT EXISTS blog_likes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  blog_id uuid REFERENCES blogs(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, blog_id)
);

-- Create comments table
CREATE TABLE IF NOT EXISTS comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  blog_id uuid REFERENCES blogs(id) ON DELETE CASCADE,
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  content text NOT NULL,
  parent_id uuid REFERENCES comments(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CHECK (
    (blog_id IS NOT NULL AND course_id IS NULL) OR 
    (blog_id IS NULL AND course_id IS NOT NULL)
  )
);

-- Create newsletter subscriptions table
CREATE TABLE IF NOT EXISTS newsletter_subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  subscribed_at timestamptz DEFAULT now(),
  active boolean DEFAULT true
);

-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE newsletter_subscriptions ENABLE ROW LEVEL SECURITY;

-- Create policies for user_profiles
CREATE POLICY "Users can view all profiles"
  ON user_profiles FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Create policies for user_preferences
CREATE POLICY "Users can manage own preferences"
  ON user_preferences FOR ALL
  TO authenticated
  USING (auth.uid() = user_id);

-- Create policies for course_enrollments
CREATE POLICY "Users can view own enrollments"
  ON course_enrollments FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can enroll in courses"
  ON course_enrollments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own enrollment progress"
  ON course_enrollments FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

-- Create policies for blog_likes
CREATE POLICY "Users can view all likes"
  ON blog_likes FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Users can manage own likes"
  ON blog_likes FOR ALL
  TO authenticated
  USING (auth.uid() = user_id);

-- Create policies for comments
CREATE POLICY "Comments are viewable by everyone"
  ON comments FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Authenticated users can create comments"
  ON comments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments"
  ON comments FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments"
  ON comments FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Create policies for newsletter
CREATE POLICY "Anyone can subscribe to newsletter"
  ON newsletter_subscriptions FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Anyone can view newsletter subscriptions"
  ON newsletter_subscriptions FOR SELECT
  TO anon, authenticated
  USING (true);

-- Insert additional comprehensive blog content
INSERT INTO blogs (title, content, snippet, image, tags, author, featured) VALUES
(
  'Building Your First Robot: A Complete Guide',
  '<h2>Welcome to Robot Building!</h2><p>Building your first robot is an exciting journey that combines creativity, engineering, and programming. This comprehensive guide will walk you through every step of the process.</p><h3>Planning Your Robot</h3><p>Before you start building, it''s important to plan what you want your robot to do:</p><ul><li>Define the robot''s purpose (cleaning, entertainment, education)</li><li>Set a realistic budget</li><li>Choose appropriate components</li><li>Design the mechanical structure</li></ul><h3>Essential Components</h3><p>Every robot needs these basic components:</p><ol><li><strong>Microcontroller</strong> - The brain of your robot (Arduino, Raspberry Pi)</li><li><strong>Motors</strong> - For movement (servo, stepper, DC motors)</li><li><strong>Sensors</strong> - To perceive the environment (ultrasonic, camera, IMU)</li><li><strong>Power Supply</strong> - Batteries or power adapters</li><li><strong>Chassis</strong> - The physical structure</li></ol><h3>Step-by-Step Building Process</h3><p>Follow these steps to build your robot:</p><h4>1. Design the Chassis</h4><p>Start with a simple design using materials like:</p><ul><li>Acrylic sheets</li><li>3D printed parts</li><li>Aluminum extrusions</li><li>Cardboard (for prototyping)</li></ul><h4>2. Install the Electronics</h4><p>Mount your microcontroller and connect the components:</p><pre><code>// Basic Arduino setup for robot control
#include &lt;Servo.h&gt;

Servo leftMotor;
Servo rightMotor;

void setup() {
  leftMotor.attach(9);
  rightMotor.attach(10);
  Serial.begin(9600);
}

void loop() {
  // Move forward
  leftMotor.write(180);
  rightMotor.write(0);
  delay(1000);
  
  // Stop
  leftMotor.write(90);
  rightMotor.write(90);
  delay(500);
}</code></pre><h4>3. Programming Your Robot</h4><p>Start with simple behaviors and gradually add complexity:</p><ul><li>Basic movement (forward, backward, turn)</li><li>Obstacle avoidance</li><li>Remote control</li><li>Autonomous navigation</li></ul><h3>Testing and Debugging</h3><p>Testing is crucial for a successful robot:</p><ul><li>Test each component individually</li><li>Use serial monitoring for debugging</li><li>Start with simple programs</li><li>Document your code</li></ul><h3>Common Challenges and Solutions</h3><p>Here are some common issues and how to solve them:</p><ul><li><strong>Power Issues</strong> - Check connections and battery levels</li><li><strong>Motor Problems</strong> - Verify wiring and power requirements</li><li><strong>Sensor Errors</strong> - Calibrate sensors and check for interference</li><li><strong>Programming Bugs</strong> - Use debugging tools and test incrementally</li></ul><p>Remember, building robots is a learning process. Don''t be discouraged by initial failures – they''re part of the journey!</p>',
  'A comprehensive step-by-step guide to building your first robot, from planning to programming.',
  'https://images.pexels.com/photos/8566473/pexels-photo-8566473.jpeg?auto=compress&cs=tinysrgb&w=800',
  ARRAY['Beginner', 'Hardware', 'Arduino', 'Tutorial'],
  'Prof. Michael Chen',
  true
),
(
  'The Future of Humanoid Robots',
  '<h2>Humanoid Robots: The Next Frontier</h2><p>Humanoid robots represent one of the most fascinating and challenging areas of robotics. These machines, designed to resemble and interact like humans, are pushing the boundaries of what''s possible in robotics.</p><h3>Current State of Humanoid Robotics</h3><p>Today''s humanoid robots have achieved remarkable capabilities:</p><ul><li><strong>Boston Dynamics Atlas</strong> - Advanced mobility and agility</li><li><strong>Honda ASIMO</strong> - Pioneering bipedal locomotion</li><li><strong>SoftBank Pepper</strong> - Social interaction and emotion recognition</li><li><strong>Tesla Optimus</strong> - General-purpose humanoid worker</li></ul><h3>Key Technologies</h3><p>Several breakthrough technologies are driving humanoid robot development:</p><h4>Advanced Actuators</h4><p>Modern humanoid robots use sophisticated actuators:</p><ul><li>Electric motors with high torque-to-weight ratios</li><li>Hydraulic systems for powerful movements</li><li>Pneumatic muscles for natural motion</li><li>Series elastic actuators for safe human interaction</li></ul><h4>AI and Machine Learning</h4><p>Artificial intelligence enables humanoid robots to:</p><ul><li>Understand and respond to natural language</li><li>Recognize faces and emotions</li><li>Learn from demonstrations</li><li>Adapt to new environments</li></ul><h4>Sensor Integration</h4><p>Humanoid robots rely on multiple sensor types:</p><ul><li>Vision systems (cameras, depth sensors)</li><li>Inertial measurement units (IMUs)</li><li>Force and torque sensors</li><li>Tactile sensors for touch</li></ul><h3>Applications and Use Cases</h3><p>Humanoid robots are being developed for various applications:</p><h4>Healthcare</h4><ul><li>Patient care and assistance</li><li>Rehabilitation therapy</li><li>Elderly companion robots</li><li>Medical procedure assistance</li></ul><h4>Service Industry</h4><ul><li>Hotel and restaurant service</li><li>Retail customer assistance</li><li>Security and surveillance</li><li>Cleaning and maintenance</li></ul><h4>Education</h4><ul><li>Interactive teaching assistants</li><li>Language learning companions</li><li>STEM education demonstrations</li><li>Special needs support</li></ul><h3>Challenges and Limitations</h3><p>Despite significant progress, humanoid robots face several challenges:</p><ul><li><strong>Power Consumption</strong> - High energy requirements limit operation time</li><li><strong>Cost</strong> - Complex systems are expensive to manufacture</li><li><strong>Reliability</strong> - Mechanical complexity increases failure points</li><li><strong>Safety</strong> - Ensuring safe human-robot interaction</li><li><strong>Uncanny Valley</strong> - Psychological barriers to acceptance</li></ul><h3>Future Developments</h3><p>The next decade promises exciting developments:</p><ul><li>Improved battery technology for longer operation</li><li>Advanced AI for better human understanding</li><li>Soft robotics for safer interaction</li><li>Mass production reducing costs</li><li>Integration with IoT and smart environments</li></ul><p>Humanoid robots will likely become increasingly common in our daily lives, transforming how we work, learn, and interact with technology.</p>',
  'Exploring the current state and future potential of humanoid robots in various industries.',
  'https://images.pexels.com/photos/8566473/pexels-photo-8566473.jpeg?auto=compress&cs=tinysrgb&w=800',
  ARRAY['Humanoid', 'AI', 'Future Tech', 'Advanced'],
  'Dr. Emily Rodriguez',
  true
),
(
  'ROS 2: The Next Generation Robot Operating System',
  '<h2>Introduction to ROS 2</h2><p>ROS 2 (Robot Operating System 2) represents a significant evolution from the original ROS, designed to address the limitations of its predecessor and meet the demands of modern robotics applications.</p><h3>Why ROS 2?</h3><p>ROS 2 was developed to overcome several limitations of ROS 1:</p><ul><li><strong>Real-time Performance</strong> - Better support for real-time applications</li><li><strong>Security</strong> - Built-in security features for commercial applications</li><li><strong>Multi-robot Systems</strong> - Improved support for robot swarms</li><li><strong>Cross-platform</strong> - Native support for Windows, macOS, and Linux</li><li><strong>Embedded Systems</strong> - Optimized for resource-constrained devices</li></ul><h3>Key Features of ROS 2</h3><h4>DDS (Data Distribution Service)</h4><p>ROS 2 uses DDS as its middleware, providing:</p><ul><li>Reliable data distribution</li><li>Quality of Service (QoS) policies</li><li>Automatic discovery of nodes</li><li>Built-in security</li></ul><h4>Node Lifecycle Management</h4><p>ROS 2 introduces managed nodes with defined states:</p><pre><code>// Example of a managed node in ROS 2
#include "rclcpp/rclcpp.hpp"
#include "rclcpp_lifecycle/lifecycle_node.hpp"

class MyLifecycleNode : public rclcpp_lifecycle::LifecycleNode
{
public:
  MyLifecycleNode() : LifecycleNode("my_lifecycle_node") {}

  rclcpp_lifecycle::node_interfaces::LifecycleNodeInterface::CallbackReturn
  on_configure(const rclcpp_lifecycle::State &)
  {
    RCLCPP_INFO(get_logger(), "Configuring node...");
    // Initialize resources
    return rclcpp_lifecycle::node_interfaces::LifecycleNodeInterface::CallbackReturn::SUCCESS;
  }

  rclcpp_lifecycle::node_interfaces::LifecycleNodeInterface::CallbackReturn
  on_activate(const rclcpp_lifecycle::State &)
  {
    RCLCPP_INFO(get_logger(), "Activating node...");
    // Start processing
    return rclcpp_lifecycle::node_interfaces::LifecycleNodeInterface::CallbackReturn::SUCCESS;
  }
};</code></pre><h4>Improved Build System</h4><p>ROS 2 uses modern build tools:</p><ul><li><strong>ament</strong> - New build system based on CMake</li><li><strong>colcon</strong> - Build tool for multiple packages</li><li><strong>Python setuptools</strong> - For Python packages</li></ul><h3>Getting Started with ROS 2</h3><h4>Installation</h4><p>Install ROS 2 on Ubuntu:</p><pre><code># Add ROS 2 repository
sudo apt update && sudo apt install curl gnupg lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

# Install ROS 2
sudo apt update
sudo apt install ros-humble-desktop</code></pre><h4>Creating Your First Package</h4><pre><code># Create workspace
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws/src

# Create package
ros2 pkg create --build-type ament_cmake my_robot_package

# Build workspace
cd ~/ros2_ws
colcon build

# Source workspace
source install/setup.bash</code></pre><h3>Advanced Features</h3><h4>Quality of Service (QoS)</h4><p>ROS 2 allows fine-tuning of communication:</p><pre><code>// Setting QoS policies
auto qos = rclcpp::QoS(rclcpp::KeepLast(10))
  .reliability(rclcpp::ReliabilityPolicy::Reliable)
  .durability(rclcpp::DurabilityPolicy::TransientLocal);

publisher_ = this->create_publisher&lt;std_msgs::msg::String&gt;("topic", qos);</code></pre><h4>Actions</h4><p>ROS 2 actions provide feedback for long-running tasks:</p><pre><code>// Action client example
auto action_client = rclcpp_action::create_client&lt;Fibonacci&gt;(node, "fibonacci");

auto goal_msg = Fibonacci::Goal();
goal_msg.order = 10;

auto send_goal_options = rclcpp_action::Client&lt;Fibonacci&gt;::SendGoalOptions();
send_goal_options.feedback_callback = feedback_callback;
send_goal_options.result_callback = result_callback;

action_client->async_send_goal(goal_msg, send_goal_options);</code></pre><h3>Migration from ROS 1</h3><p>Migrating from ROS 1 to ROS 2 involves:</p><ul><li>Updating package.xml format</li><li>Converting CMakeLists.txt</li><li>Updating C++ and Python code</li><li>Adapting launch files</li></ul><h3>Best Practices</h3><ul><li>Use lifecycle nodes for critical components</li><li>Implement proper QoS policies</li><li>Follow ROS 2 naming conventions</li><li>Use composition for better performance</li><li>Implement proper error handling</li></ul><p>ROS 2 represents the future of robot software development, offering improved performance, security, and flexibility for next-generation robotic systems.</p>',
  'A comprehensive guide to ROS 2, the next-generation robot operating system with improved features.',
  'https://images.pexels.com/photos/8566473/pexels-photo-8566473.jpeg?auto=compress&cs=tinysrgb&w=800',
  ARRAY['ROS', 'Software', 'Advanced', 'Programming'],
  'Dr. Sarah Johnson',
  false
),
(
  'Computer Vision in Robotics: From Theory to Practice',
  '<h2>Computer Vision: The Eyes of Robots</h2><p>Computer vision enables robots to perceive and understand their visual environment, making it one of the most crucial technologies in modern robotics.</p><h3>Fundamentals of Computer Vision</h3><p>Computer vision in robotics involves several key concepts:</p><ul><li><strong>Image Acquisition</strong> - Capturing visual data through cameras</li><li><strong>Image Processing</strong> - Enhancing and filtering images</li><li><strong>Feature Detection</strong> - Identifying important visual elements</li><li><strong>Object Recognition</strong> - Classifying and identifying objects</li><li><strong>Scene Understanding</strong> - Interpreting the overall environment</li></ul><h3>Essential Algorithms</h3><h4>Edge Detection</h4><p>Edge detection helps identify object boundaries:</p><pre><code>import cv2
import numpy as np

# Load image
image = cv2.imread("robot_scene.jpg", cv2.IMREAD_GRAYSCALE)

# Apply Canny edge detection
edges = cv2.Canny(image, 50, 150)

# Display result
cv2.imshow("Edges", edges)
cv2.waitKey(0)</code></pre><h4>Object Detection with YOLO</h4><p>YOLO (You Only Look Once) is popular for real-time object detection:</p><pre><code>import cv2
import numpy as np

# Load YOLO model
net = cv2.dnn.readNet("yolov4.weights", "yolov4.cfg")
classes = open("coco.names").read().strip().split("\\n")

# Process image
blob = cv2.dnn.blobFromImage(image, 1/255.0, (416, 416), swapRB=True, crop=False)
net.setInput(blob)
outputs = net.forward()

# Extract detections
for output in outputs:
    for detection in output:
        scores = detection[5:]
        class_id = np.argmax(scores)
        confidence = scores[class_id]
        
        if confidence > 0.5:
            # Process detection
            center_x = int(detection[0] * width)
            center_y = int(detection[1] * height)
            # ... draw bounding box</code></pre><h3>3D Vision and Depth Perception</h3><p>Robots often need to understand 3D space:</p><h4>Stereo Vision</h4><ul><li>Uses two cameras to calculate depth</li><li>Mimics human binocular vision</li><li>Provides accurate distance measurements</li></ul><h4>Structured Light</h4><ul><li>Projects known patterns onto scenes</li><li>Analyzes pattern distortion for depth</li><li>Used in devices like Kinect</li></ul><h4>Time-of-Flight Cameras</h4><ul><li>Measures light travel time</li><li>Provides real-time depth maps</li><li>Good for dynamic environments</li></ul><h3>Applications in Robotics</h3><h4>Navigation and SLAM</h4><p>Visual SLAM (Simultaneous Localization and Mapping):</p><ul><li>ORB-SLAM for feature-based mapping</li><li>Direct methods like DSO</li><li>Visual-inertial odometry</li></ul><h4>Manipulation</h4><p>Vision-guided robot manipulation:</p><ul><li>Object pose estimation</li><li>Grasp planning</li><li>Visual servoing</li><li>Quality inspection</li></ul><h4>Human-Robot Interaction</h4><ul><li>Face recognition and tracking</li><li>Gesture recognition</li><li>Emotion detection</li><li>Gaze estimation</li></ul><h3>Deep Learning in Computer Vision</h3><h4>Convolutional Neural Networks (CNNs)</h4><p>CNNs revolutionized computer vision:</p><pre><code>import tensorflow as tf
from tensorflow.keras import layers

# Simple CNN for object classification
model = tf.keras.Sequential([
    layers.Conv2D(32, (3, 3), activation="relu", input_shape=(224, 224, 3)),
    layers.MaxPooling2D((2, 2)),
    layers.Conv2D(64, (3, 3), activation="relu"),
    layers.MaxPooling2D((2, 2)),
    layers.Conv2D(64, (3, 3), activation="relu"),
    layers.Flatten(),
    layers.Dense(64, activation="relu"),
    layers.Dense(10, activation="softmax")
])

model.compile(optimizer="adam",
              loss="sparse_categorical_crossentropy",
              metrics=["accuracy"])</code></pre><h4>Transfer Learning</h4><p>Using pre-trained models for robotics applications:</p><ul><li>ImageNet pre-trained models</li><li>Fine-tuning for specific tasks</li><li>Reduced training time and data requirements</li></ul><h3>Challenges and Solutions</h3><h4>Lighting Conditions</h4><ul><li>Adaptive exposure control</li><li>HDR imaging techniques</li><li>Infrared and thermal imaging</li></ul><h4>Real-time Processing</h4><ul><li>GPU acceleration</li><li>Model optimization and quantization</li><li>Edge computing solutions</li></ul><h4>Robustness</h4><ul><li>Data augmentation</li><li>Multi-modal sensor fusion</li><li>Uncertainty estimation</li></ul><h3>Future Trends</h3><ul><li><strong>Neuromorphic Vision</strong> - Event-based cameras</li><li><strong>Self-supervised Learning</strong> - Reducing annotation requirements</li><li><strong>Embodied AI</strong> - Learning through interaction</li><li><strong>Quantum Computing</strong> - Potential for complex vision tasks</li></ul><p>Computer vision continues to evolve rapidly, enabling robots to see and understand the world with increasing sophistication and reliability.</p>',
  'Comprehensive guide to computer vision techniques and applications in modern robotics systems.',
  'https://images.pexels.com/photos/8566473/pexels-photo-8566473.jpeg?auto=compress&cs=tinysrgb&w=800',
  ARRAY['Computer Vision', 'AI', 'Programming', 'Advanced'],
  'Prof. Michael Chen',
  true
);

-- Insert additional comprehensive course content
INSERT INTO courses (title, description, content, image, duration, category, video_url, materials, featured) VALUES
(
  'Autonomous Drone Programming',
  'Learn to program autonomous drones using Python, ROS, and computer vision for various applications.',
  '<h2>Course Overview</h2><p>This comprehensive course teaches you how to program autonomous drones from scratch. You''ll learn flight control, computer vision, and autonomous navigation.</p><h3>Prerequisites</h3><ul><li>Basic Python programming</li><li>Understanding of physics and mathematics</li><li>Familiarity with Linux command line</li></ul><h3>What You''ll Learn</h3><ul><li>Drone hardware and components</li><li>Flight dynamics and control theory</li><li>PX4 and ArduPilot flight stacks</li><li>Computer vision for drones</li><li>Autonomous mission planning</li><li>Safety protocols and regulations</li></ul><h3>Course Modules</h3><h4>Module 1: Drone Fundamentals</h4><ul><li>Quadcopter physics and aerodynamics</li><li>Electronic speed controllers (ESCs)</li><li>Flight control units (FCUs)</li><li>Sensors: IMU, GPS, barometer</li></ul><h4>Module 2: Flight Control Programming</h4><ul><li>PID controllers for stability</li><li>Attitude and position control</li><li>Waypoint navigation</li><li>Emergency procedures</li></ul><h4>Module 3: Computer Vision Integration</h4><ul><li>Camera calibration and setup</li><li>Object detection and tracking</li><li>Visual odometry</li><li>SLAM for indoor navigation</li></ul><h4>Module 4: Autonomous Missions</h4><ul><li>Mission planning software</li><li>Obstacle avoidance algorithms</li><li>Return-to-home functionality</li><li>Multi-drone coordination</li></ul><h3>Hands-on Projects</h3><ol><li><strong>Basic Flight Control</strong> - Program basic flight maneuvers</li><li><strong>Follow Me Mode</strong> - Drone follows a moving target</li><li><strong>Autonomous Mapping</strong> - Create maps using onboard sensors</li><li><strong>Search and Rescue</strong> - Autonomous search patterns</li><li><strong>Delivery System</strong> - Autonomous package delivery</li></ol><h3>Safety and Regulations</h3><p>Understanding drone regulations is crucial:</p><ul><li>FAA Part 107 certification</li><li>No-fly zones and airspace restrictions</li><li>Safety checklists and procedures</li><li>Emergency landing protocols</li></ul><h3>Tools and Software</h3><ul><li>QGroundControl for mission planning</li><li>SITL (Software In The Loop) simulation</li><li>Gazebo for 3D simulation</li><li>OpenCV for computer vision</li><li>ROS for system integration</li></ul>',
  'https://images.pexels.com/photos/8566473/pexels-photo-8566473.jpeg?auto=compress&cs=tinysrgb&w=800',
  '16 weeks',
  'Advanced',
  'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  ARRAY['Drone Hardware Kit', 'Flight Simulator Access', 'Programming Exercises', 'Safety Manual'],
  true
),
(
  'Industrial Robot Programming',
  'Master industrial robot programming for manufacturing applications using industry-standard tools.',
  '<h2>Industrial Robotics Mastery</h2><p>This course provides comprehensive training in industrial robot programming, focusing on real-world manufacturing applications.</p><h3>Course Objectives</h3><ul><li>Understand industrial robot kinematics</li><li>Master robot programming languages</li><li>Learn safety standards and protocols</li><li>Implement automation solutions</li><li>Optimize robot performance</li></ul><h3>Robot Types Covered</h3><ul><li>6-axis articulated robots</li><li>SCARA robots</li><li>Delta/parallel robots</li><li>Collaborative robots (cobots)</li></ul><h3>Programming Languages</h3><h4>ABB RAPID</h4><pre><code>MODULE MainModule
    CONST robtarget pHome := [[300,0,500],[1,0,0,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget pPick := [[400,200,100],[1,0,0,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    PROC main()
        MoveJ pHome, v1000, z50, tool0;
        MoveL pPick, v500, z10, tool0;
        ! Pick operation
        SetDO gripper, 1;
        WaitTime 0.5;
        MoveL pHome, v500, z10, tool0;
    ENDPROC
ENDMODULE</code></pre><h4>KUKA KRL</h4><pre><code>DEF PickAndPlace()
    PTP HOME Vel=100% DEFAULT
    LIN PICK Vel=0.5 m/s CPDAT1
    ; Activate gripper
    $OUT[1] = TRUE
    WAIT SEC 0.5
    LIN HOME Vel=0.5 m/s CPDAT1
END</code></pre><h3>Applications</h3><ul><li>Pick and place operations</li><li>Welding automation</li><li>Painting and coating</li><li>Assembly line integration</li><li>Quality inspection</li><li>Material handling</li></ul>',
  'https://images.pexels.com/photos/8566473/pexels-photo-8566473.jpeg?auto=compress&cs=tinysrgb&w=800',
  '14 weeks',
  'Advanced',
  'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  ARRAY['Robot Simulator License', 'Programming Manual', 'Safety Certification', 'Project Templates'],
  false
),
(
  'AI and Machine Learning for Robotics',
  'Integrate artificial intelligence and machine learning techniques into robotic systems.',
  '<h2>AI-Powered Robotics</h2><p>This advanced course explores the integration of AI and ML techniques in robotics, enabling intelligent and adaptive robot behavior.</p><h3>Course Structure</h3><h4>Part 1: Foundations</h4><ul><li>Introduction to AI in robotics</li><li>Machine learning fundamentals</li><li>Neural networks and deep learning</li><li>Reinforcement learning basics</li></ul><h4>Part 2: Perception</h4><ul><li>Computer vision with CNNs</li><li>Object detection and recognition</li><li>Semantic segmentation</li><li>Multi-modal sensor fusion</li></ul><h4>Part 3: Decision Making</h4><ul><li>Path planning with AI</li><li>Behavior trees and state machines</li><li>Multi-agent systems</li><li>Swarm intelligence</li></ul><h4>Part 4: Learning and Adaptation</h4><ul><li>Imitation learning</li><li>Transfer learning</li><li>Online learning and adaptation</li><li>Meta-learning for robotics</li></ul><h3>Practical Projects</h3><ol><li>Vision-based object manipulation</li><li>Autonomous navigation with RL</li><li>Human-robot collaboration</li><li>Adaptive control systems</li></ol>',
  'https://images.pexels.com/photos/8566473/pexels-photo-8566473.jpeg?auto=compress&cs=tinysrgb&w=800',
  '18 weeks',
  'Advanced',
  'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  ARRAY['GPU Computing Access', 'AI Framework Licenses', 'Dataset Collections', 'Research Papers'],
  true
),
(
  'Robot Operating System (ROS) Fundamentals',
  'Master the Robot Operating System (ROS) framework for building complex robotic applications.',
  '<h2>ROS Fundamentals Course</h2><p>Learn the Robot Operating System (ROS), the most popular framework for robot software development.</p><h3>Course Overview</h3><p>This course covers ROS from basics to advanced topics, preparing you to develop professional robotic applications.</p><h3>Learning Path</h3><h4>Week 1-2: ROS Basics</h4><ul><li>ROS architecture and concepts</li><li>Nodes, topics, and messages</li><li>Services and actions</li><li>Parameter server</li></ul><h4>Week 3-4: ROS Tools</h4><ul><li>roslaunch and launch files</li><li>rosbag for data recording</li><li>rviz for visualization</li><li>rqt tools for debugging</li></ul><h4>Week 5-6: Programming in ROS</h4><ul><li>Writing ROS nodes in Python</li><li>C++ development with ROS</li><li>Custom message types</li><li>Package creation and management</li></ul><h4>Week 7-8: Advanced Topics</h4><ul><li>TF (Transform) library</li><li>Navigation stack</li><li>MoveIt! for manipulation</li><li>Gazebo simulation</li></ul><h3>Hands-on Projects</h3><ol><li>Turtle control with ROS</li><li>Sensor data processing</li><li>Robot arm control</li><li>Autonomous navigation</li><li>Multi-robot coordination</li></ol>',
  'https://images.pexels.com/photos/8566473/pexels-photo-8566473.jpeg?auto=compress&cs=tinysrgb&w=800',
  '8 weeks',
  'Intermediate',
  'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  ARRAY['ROS Installation Guide', 'Virtual Machine Image', 'Code Examples', 'Project Templates'],
  false
);

-- Insert dummy admin user data (Note: This is for demonstration only)
-- In production, users would be created through Supabase Auth
INSERT INTO user_profiles (user_id, email, full_name, avatar_url, bio, role) VALUES
(
  gen_random_uuid(),
  'admin@robostaan.com',
  'Admin User',
  'https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=400',
  'System administrator with full access to manage content and users.',
  'admin'
),
(
  gen_random_uuid(),
  'instructor@robostaan.com',
  'Dr. Sarah Johnson',
  'https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=400',
  'Lead instructor specializing in robotics programming and AI integration.',
  'instructor'
);