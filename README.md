# 🚗 CarZen

**CarZen** is an intelligent automobile marketplace and vehicle management platform that connects **car buyers, sellers, and resellers**. The project is developed using **Python, FastAPI, MySQL, Flutter, and Machine Learning** to simplify the car-buying, selling, and ownership experience.

---

## 📌 Overview

CarZen provides a digital platform where users can explore available vehicles, view detailed vehicle information, manage listings, purchase cars, and manage their vehicle-related activities through a modern and responsive interface.

The platform follows a client-server architecture:

- **Flutter** — Cross-platform user interface
- **FastAPI** — Backend REST API
- **MySQL** — Relational database
- **Python** — Backend and Machine Learning development
- **Machine Learning** — Intelligent automobile-related functionality

The project is being developed as a full-stack academic project with a focus on creating a practical and scalable automobile marketplace.

---

## ✨ Features

### 🏠 Home & Vehicle Discovery

- Modern automobile marketplace homepage
- Browse available vehicles
- Search and filter vehicle listings
- View vehicle categories and information
- Responsive interface for different screen sizes

### 🚘 Car Marketplace

- Browse available cars
- View complete vehicle details
- Vehicle images and media
- Pricing and vehicle information
- Listing details and availability

### 💰 Sell & Resell Cars

- Create vehicle listings
- Add vehicle information
- Upload vehicle media
- Manage vehicle listings
- Support for selling and reselling vehicles

### 👤 User Authentication

- User registration
- User login
- Secure token-based authentication
- Persistent login session
- Profile management
- Protected user operations

### ❤️ Favorites

- Add cars to favorites
- Remove cars from favorites
- View saved vehicles

### 🛒 Orders

- Purchase-related order management
- View user orders
- Order details and status
- Admin order management

### 👨‍💼 Administration

- Admin authentication
- User management
- Order management
- Administrative controls
- Vehicle and listing management capabilities

### 🔧 Vehicle Services

The application is designed to support vehicle-related services and service management where corresponding backend functionality is available.

### 🧰 Car Accessories

The application structure supports automobile accessories functionality where corresponding backend functionality is available.

### 🤖 Machine Learning

Machine Learning is included as part of the CarZen project to provide intelligent automobile-related functionality.

---

## 🏗️ System Architecture

```text
┌──────────────────────────────┐
│          Flutter UI          │
│                              │
│  Home • Buy • Sell • Profile │
│  Favorites • Orders • Admin  │
└──────────────┬───────────────┘
               │
               │ REST API
               ▼
┌──────────────────────────────┐
│        FastAPI Backend       │
│                              │
│ Authentication               │
│ Users                        │
│ Cars / Listings              │
│ Favorites                    │
│ Orders                       │
│ Admin                        │
│ ML Integration               │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│          MySQL DB            │
│                              │
│ Users                        │
│ Cars                         │
│ Listings                     │
│ Orders                       │
│ Favorites                    │
│ Payments / Related Data      │
└──────────────────────────────┘
```

---

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Frontend / Cross-platform UI |
| **Dart** | Flutter application development |
| **Python** | Backend and Machine Learning |
| **FastAPI** | REST API backend |
| **MySQL** | Database |
| **Machine Learning** | Intelligent automobile features |
| **Git** | Version control |
| **GitHub** | Source code management |
| **Swagger / OpenAPI** | API documentation and testing |

---

## 📂 Project Structure

```text
CarZen/
│
├── backend/
│   ├── ...
│   └── requirements.txt
│
├── CarZen_UI/
│   ├── lib/
│   │   ├── models/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── theme/
│   │   ├── utils/
│   │   └── widgets/
│   │
│   ├── assets/
│   ├── pubspec.yaml
│   └── ...
│
├── docs/
│   └── Database SQL file
│
├── ml/
│   └── ...
│
├── uploads/
│   └── ...
│
├── .gitattributes
├── LICENSE
├── README.md
└── ...
```

---

## 🔐 Authentication & Authorization

CarZen uses token-based authentication between the Flutter application and FastAPI backend.

The platform supports two primary user roles:

- **User** — Can access marketplace and user-level functionality such as browsing, buying, selling/reselling vehicles, favorites, orders, and other supported features.
- **Admin** — Provides administrative functionality such as user and order management.

Public marketplace content can be accessed without requiring users to log in. Authentication is required when accessing protected operations.

---

## 🔄 Application Flow

```text
                ┌─────────────┐
                │    User     │
                └──────┬──────┘
                       │
                       ▼
                ┌─────────────┐
                │  Flutter UI │
                └──────┬──────┘
                       │
                 REST API Calls
                       │
                       ▼
                ┌─────────────┐
                │   FastAPI   │
                └──────┬──────┘
                       │
             ┌─────────┴─────────┐
             ▼                   ▼
       ┌───────────┐       ┌───────────┐
       │   MySQL   │       │     ML    │
       │ Database  │       │ Components│
       └───────────┘       └───────────┘
```

---

## 🚀 Getting Started

### Prerequisites

Make sure the following are installed:

- Flutter SDK
- Dart SDK
- Python 3.x
- MySQL Server
- Git
- Android Studio / VS Code
- A supported web or mobile environment for Flutter

---

### 1. Clone the Repository

```bash
git clone https://github.com/VishalChudasama08/CarZen.git
cd CarZen
```

---

### 2. Backend Setup

Navigate to the backend directory:

```powershell
cd backend
```

Create a Python virtual environment:

```powershell
python -m venv .venv
```

#### Windows PowerShell

If activation is blocked by the PowerShell execution policy, run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Then activate the environment:

```powershell
.\.venv\Scripts\Activate.ps1
```

You should see `(.venv)` at the beginning of the terminal prompt.

Install the required dependencies:

```powershell
python -m pip install --upgrade pip
pip install -r requirements.txt
```

### 3. Database Setup

Create the MySQL database according to the backend configuration.

The database SQL file is available inside the `docs/` directory. Import it into MySQL to create the required database structure and data.

Configure the `.env` file with your local MySQL configuration:

```env
DATABASE_NAME=carzen_db_v1
DATABASE_USER=root
DATABASE_PASSWORD=your_password
```

Do not commit real passwords, API keys, payment credentials, or other secrets to GitHub.

### 4. Run the Backend

Make sure the virtual environment is activated:

```powershell
.\.venv\Scripts\Activate.ps1
```

From the `backend` directory, run:

```powershell
python run.py
```

The FastAPI server will normally be available at:

```text
http://127.0.0.1:8000
```

FastAPI Swagger documentation:

```text
http://127.0.0.1:8000/docs
```

### 5. Run the Flutter Application

Open another terminal and navigate to the Flutter project:

```bash
cd CarZen_UI
```

Install Flutter dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

For Flutter Web:

```bash
flutter run -d chrome
```

---

## 🧪 Testing

Backend APIs can be tested using:

- FastAPI Swagger UI
- Postman
- Bruno
- Other REST API clients

Flutter code can be analyzed using:

```bash
flutter analyze
```

The application should be tested across relevant screen sizes and platforms to ensure responsive behavior.

---

## 🔌 API Architecture

The Flutter application communicates with the FastAPI backend through REST APIs.

Major API areas include functionality related to:

```text
Authentication
Users
Cars
Listings
Favorites
Orders
Administration
```

The exact available endpoints are defined by the FastAPI backend and its OpenAPI documentation.

---

## 🗄️ Database

CarZen uses **MySQL** as its relational database.

The database contains data related to areas such as:

- Users
- Cars
- Listings
- Favorites
- Orders
- Payments
- Ownership information
- Other automobile marketplace data

The database SQL file required for setup is included in the project's **`docs/` directory**.

---

## 🤖 Machine Learning

Machine Learning is included as part of the CarZen platform to provide intelligent automobile-related functionality.

The ML component can be integrated with the automobile marketplace to support data-driven features such as:

- Vehicle-related predictions
- Recommendations
- Automobile data analysis
- Other intelligent functionality

The exact ML capabilities may evolve as the project progresses.

---

## 📱 Responsive Design

CarZen is designed to provide a responsive experience across:

- 📱 Mobile
- 📲 Tablet
- 💻 Desktop
- 🌐 Web

The Flutter UI uses reusable widgets and responsive layouts to maintain a consistent user experience across different screen sizes.

---

## 🔒 Security Considerations

The project follows basic security practices including:

- Token-based authentication
- Protected API operations
- Password hashing through the backend authentication system
- Environment variables for sensitive configuration
- Separation of frontend and backend
- Role-based access control

For production deployment, additional security measures such as HTTPS, secure secret management, rate limiting, input validation, logging, and production database configuration should be implemented.

---

## 🎯 Project Goals

The main goals of CarZen are to:

1. Simplify the process of buying and selling cars.
2. Provide a centralized automobile marketplace.
3. Make vehicle information easily accessible.
4. Provide users with tools to manage their vehicle-related activities.
5. Integrate Machine Learning into an automobile marketplace.
6. Provide a modern cross-platform user experience.
7. Build a scalable full-stack application using modern technologies.

---

## 🔮 Future Scope

Possible future improvements include:

- Advanced ML-based vehicle recommendations
- Vehicle price prediction
- Improved search and filtering
- Online payment integration
- Vehicle service booking
- Accessories marketplace
- Notifications
- Messaging between buyers and sellers
- Advanced admin analytics
- Cloud deployment
- Improved recommendation systems

---

## 👨‍💻 Development Team

**CarZen — MCA Semester 3 Project**

Developed using:

**Flutter + Python + FastAPI + MySQL + Machine Learning**

---

## 📄 License

This project is developed for **educational and academic purposes**.

See the [`LICENSE`](LICENSE) file for the applicable license terms.

---

## ⭐ CarZen

If you find the project interesting, consider giving the repository a ⭐ on GitHub.