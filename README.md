# ShortLink - Professional URL Shortening Service

<div align="center">

**Transform long, unwieldy URLs into short, shareable links with enterprise-grade reliability**

[![Ruby](https://img.shields.io/badge/Ruby-3.3+-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.0.2-red.svg)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12+-blue.svg)](https://www.postgresql.org/)
[![RSpec](https://img.shields.io/badge/Tests-RSpec-green.svg)](https://rspec.info/)

</div>

---

## 🎯 Overview

**ShortLink** is a production-ready URL shortening service that transforms lengthy URLs into concise, memorable short links. Built with Ruby on Rails, it provides a robust RESTful API for encoding and decoding URLs with enterprise-level security, scalability, and reliability.

### The Problem It Solves

Long URLs are difficult to share, remember, and can break in emails or messaging apps. ShortLink solves this by:
- Converting URLs like `https://codesubmit.io/library/react?category=frontend&level=advanced` 
- Into short links like `http://your.domain/GeAi9K`
- While maintaining persistence, security, and tracking capabilities

### Key Highlights

- 🔒 **Security-First Design**: HTTPS enforcement, SSRF protection, and comprehensive input validation
- 🚀 **High Performance**: Collision-free encoding using Hashids, optimized for scale
- 💾 **Persistent Storage**: PostgreSQL ensures URLs survive application restarts
- 🔐 **Dual Authentication**: API-level and user-level token authentication
- 📊 **Production Ready**: Comprehensive test coverage, error handling, and monitoring
- 🌐 **Public Decode**: Anyone can decode short URLs (no authentication required)

---

## 🛠 Technology Stack

### Core Framework
- **Ruby 3.3+** - Modern, performant Ruby version with latest features
- **Rails 8.0.2** - Latest Rails framework with enhanced performance and security
- **PostgreSQL 12+** - Robust relational database with ACID compliance

### Key Libraries & Tools
- **Hashids** - Deterministic, collision-free URL encoding algorithm
- **BCrypt** - Industry-standard password hashing for secure authentication
- **RSpec** - Comprehensive testing framework with 60+ test cases
- **FactoryBot** - Flexible test data generation
- **rails_param** - Strong parameter validation and sanitization

### Architecture & Patterns
- **RESTful API Design** - Clean, intuitive endpoint structure
- **Service Objects** - URL validation logic encapsulated in dedicated services
- **Concerns Pattern** - Reusable authentication, error handling, and response modules
- **ActiveRecord ORM** - Database abstraction with migration support

### Security Features
- **Two-Layer Authentication** - API access tokens + user session tokens
- **SSRF Protection** - Blocks localhost, private IPs, and loopback addresses
- **Input Sanitization** - Comprehensive URL validation and parameter filtering
- **Rate Limiting** - Per-user URL creation limits (1000 URLs/user)

### Development & Testing
- **RSpec** - Behavior-driven development with extensive test coverage
- **Database Cleaner** - Clean test database state between tests
- **Shoulda Matchers** - Elegant model and controller testing
- **Faker** - Realistic test data generation

---

## ✨ Features

### Core Functionality
- ✅ **URL Encoding** - Convert long URLs into short, memorable codes (e.g., `GeAi9K`)
- ✅ **URL Decoding** - Retrieve original URLs from short codes instantly
- ✅ **Public Decode Access** - Anyone can decode short URLs without authentication
- ✅ **Persistent Storage** - URLs survive application restarts and deployments

### Security & Validation
- 🔒 **HTTPS Enforcement** - Only secure HTTPS URLs are accepted
- 🛡️ **SSRF Protection** - Blocks localhost, private IPs (192.168.x.x, 10.x.x.x), and loopback addresses
- ✅ **Comprehensive URL Validation** - Format, protocol, host, and security checks
- 🔐 **Dual Authentication** - API access token + user session token for encode operations
- 🚫 **Rate Limiting** - Per-user limits prevent abuse (configurable, default: 1000 URLs/user)

### API & Integration
- 📡 **RESTful JSON API** - Clean, intuitive endpoint design
- 📝 **Proper HTTP Status Codes** - 200, 401, 404, 422, 500 with descriptive messages
- 🔄 **Idempotent Operations** - Safe to retry failed requests
- 📊 **Structured Error Responses** - Consistent JSON error format

### Developer Experience
- 🧪 **60+ Test Cases** - Comprehensive RSpec test suite
- 📚 **Detailed Documentation** - API docs, setup guides, and architecture notes
- 🐛 **Graceful Error Handling** - User-friendly error messages
- 🔧 **Environment Configuration** - Easy setup with .env files
- 📦 **Database Migrations** - Version-controlled schema changes

---

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Installation & Setup](#installation--setup)
- [API Documentation](#api-documentation)
- [Testing the API](#testing-the-api)
- [Running Tests](#running-tests)
- [Security Considerations](#security-considerations)
- [Scalability Considerations](#scalability-considerations)
- [Deployment](#deployment)
- [Contributing](#contributing)

---

## 📮 Postman Collection

**Ready-to-use Postman collection included!**

Import `ShortLink_API.postman_collection.json` into Postman to instantly test all endpoints with:
- ✅ Pre-configured requests
- ✅ Auto-saved tokens
- ✅ Error case examples
- ✅ Complete workflow

[Jump to Postman instructions →](#testing-the-api)

---

## 🚀 Quick Start

Get ShortLink up and running in 5 minutes:

```bash
# Clone the repository
git clone https://github.com/your-username/short-link.git
cd short-link

# Install dependencies
bundle install

# Setup database
cp .env.example .env
# Edit .env with your database credentials
rails db:create db:migrate db:seed

# Start the server
rails server
```

The API will be available at `http://localhost:3000`

---

## 📦 Installation & Setup

### Prerequisites

Before you begin, ensure you have the following installed:

- **Ruby 3.3+** - [Install Ruby](https://www.ruby-lang.org/en/documentation/installation/)
- **Rails 8.0+** - Installed via bundler
- **PostgreSQL 12+** - [Install PostgreSQL](https://www.postgresql.org/download/)
- **Git** - [Install Git](https://git-scm.com/downloads)
- **Bundler** - `gem install bundler`

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-username/short-link.git
cd short-link
```

### Step 2: Install Dependencies

```bash
bundle install
```

This will install all required gems including:
- Rails framework
- PostgreSQL adapter
- Authentication libraries (BCrypt)
- Testing frameworks (RSpec, FactoryBot)
- URL encoding (Hashids)
- And more...

### Step 3: Environment Configuration

Create your environment configuration file:

```bash
cp .env.example .env
```

Edit the `.env` file with your configuration:

```env
# Database Configuration
DB_USERNAME=your_postgres_username
DB_PASSWORD=your_postgres_password
DB_HOST=localhost
DB_PORT=5432

# Rails Configuration
RAILS_MAX_THREADS=5
RAILS_ENV=development
```

**Note:** The `.env` file is gitignored for security. Never commit credentials to version control.

### Step 4: Configure Rails Credentials

Set up your API access token in Rails encrypted credentials:

```bash
# For development
EDITOR="nano" rails credentials:edit
```

Add the following to the credentials file:

```yaml
api_access_token: your_secure_random_token_here
```

Generate a secure token with:

```bash
rails secret
```

**For production:**

```bash
EDITOR="nano" rails credentials:edit --environment production
```

### Step 5: Database Setup

#### Create the Database

```bash
rails db:create
```

This creates:
- `devDB10` (development)
- `testDB20` (test)

#### Run Migrations

```bash
rails db:migrate
```

This creates the following tables:
- `users` - User accounts
- `sessions` - Authentication sessions
- `short_urls` - URL mappings

#### Seed the Database (Optional)

```bash
rails db:seed
```

This creates:
- Sample user account
- Demo short URLs for testing

### Step 6: Verify Installation

Run the test suite to ensure everything is set up correctly:

```bash
bundle exec rspec
```

You should see all tests passing (60+ specs).

### Step 7: Start the Server

#### Development Mode

```bash
rails server
# or
rails s
```

The application will be available at: `http://localhost:3000`

#### Production Mode

```bash
RAILS_ENV=production rails server
```

---

## 🔧 Configuration

### Database Configuration

The application uses PostgreSQL. Configuration is in `config/database.yml`:

```yaml
development:
  adapter: postgresql
  database: devDB10
  username: <%= ENV['DB_USERNAME'] %>
  password: <%= ENV['DB_PASSWORD'] %>
  host: <%= ENV['DB_HOST'] || 'localhost' %>
  port: <%= ENV['DB_PORT'] || 5432 %>
```

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `DB_USERNAME` | PostgreSQL username | - | Yes |
| `DB_PASSWORD` | PostgreSQL password | - | Yes |
| `DB_HOST` | Database host | `localhost` | No |
| `DB_PORT` | Database port | `5432` | No |
| `RAILS_MAX_THREADS` | Max threads for Puma | `5` | No |
| `RAILS_ENV` | Environment (development/test/production) | `development` | No |

### API Access Token

The API requires an access token for all requests. This is configured in Rails credentials:

```bash
# View current credentials
rails credentials:show

# Edit credentials
EDITOR="nano" rails credentials:edit
```

---

## 🔍 Troubleshooting

### Common Issues

#### 1. PostgreSQL Connection Error

**Error:** `could not connect to server: Connection refused`

**Solution:**
```bash
# Check if PostgreSQL is running
sudo service postgresql status

# Start PostgreSQL
sudo service postgresql start

# Or on macOS with Homebrew
brew services start postgresql
```

#### 2. Database Does Not Exist

**Error:** `FATAL: database "devDB10" does not exist`

**Solution:**
```bash
rails db:create
```

#### 3. Pending Migrations

**Error:** `Migrations are pending`

**Solution:**
```bash
rails db:migrate
```

#### 4. Bundle Install Fails

**Error:** `An error occurred while installing pg`

**Solution:**
```bash
# Install PostgreSQL development headers
# Ubuntu/Debian
sudo apt-get install libpq-dev

# macOS
brew install postgresql

# Then retry
bundle install
```

#### 5. Credentials Key Missing

**Error:** `Missing encryption key to decrypt file`

**Solution:**
```bash
# Generate a new master key
rails credentials:edit
# This will create config/master.key automatically
```

---

## 📱 API Health Check

Once the server is running, verify it's working:

```bash
curl http://localhost:3000
```

Expected response: `200 OK` With server is up message

---

## 📖 API Documentation

### Base URL

```
Development: http://localhost:3000
```

### Authentication Overview

ShortLink uses a **two-layer authentication system**:

1. **API Access Token** (Required for ALL endpoints)
   - Application-level security
   - Configured in Rails credentials
   - Passed via `API-ACCESS-TOKEN` header

2. **User Session Token** (Required for encode only)
   - User-level authentication
   - Obtained via login endpoint
   - Passed via `Authorization: Bearer {token}` header

---

## 🔐 Authentication Endpoint

### Create Session (Login)

Authenticate a user and receive a session token for making authenticated requests.

**Endpoint:** `POST /api/v1/auth/sessions`

**Authentication Required:** API Access Token only

**Headers:**
```http
Content-Type: application/json
API-ACCESS-TOKEN: your_api_access_token
```

**Request Body:**
```json
{
  "email_address": "user@example.com",
  "password": "your_password"
}
```

**Success Response (200 OK):**
```json
{
  "status_code": 200,
  "success": true,
  "message": "Logged in successfully",
  "data": {
    "token": "xYz9KpQmN3vB7wL2jR8tF5hD1cS4gA6e",
    "user": {
      "id": 1,
      "email_address": "user@example.com"
    }
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "status_code": 401,
  "success": false,
  "message": "Invalid email address or password"
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:3000/api/v1/auth/sessions/create \
  -H "Content-Type: application/json" \
  -H "API-ACCESS-TOKEN: your_api_access_token" \
  -d '{
    "email_address": "user@example.com",
    "password": "password123"
  }'
```

---

## 🔗 Encode Endpoint

### Encode a URL

Converts a long URL into a shortened URL with a unique code.

**Endpoint:** `POST /api/v1/short_urls/encode`

**Authentication Required:** API Access Token + User Session Token

**Headers:**
```http
Content-Type: application/json
API-ACCESS-TOKEN: your_api_access_token
Authorization: Bearer your_session_token
```

**Request Body:**
```json
{
  "short_url": {
    "url": "https://codesubmit.io/library/react"
  }
}
```

**Success Response (200 OK):**
```json
{
  "status_code": 200,
  "success": true,
  "message": "Link encoded successfully",
  "data": {
    "encoded_url": "http://localhost:3000/api/v1/short_urls/decode/GeAi9K"
  }
}
```

**How It Works:**

1. User sends a long URL to the `/encode` endpoint
2. System validates the URL (HTTPS, valid format, not localhost/private IP)
3. URL is saved to database and receives a unique ID
4. ID is encoded using Hashids algorithm into a short code (e.g., `GeAi9K`)
5. Full shortened URL is returned to the user

**URL Validation Rules:**

- ✅ Must be a valid URL format
- ✅ Must use HTTPS protocol (HTTP is rejected)
- ✅ Must have a valid host
- ❌ Cannot be localhost
- ❌ Cannot be private IP addresses (192.168.x.x, 10.x.x.x, 172.16.x.x)
- ❌ Cannot be loopback addresses (127.0.0.1)
- ✅ Can include query parameters, fragments, ports, and paths
- ✅ Whitespace is automatically trimmed

**Error Responses:**

**400 Bad Request** - Missing or invalid parameters:
```json
{
  "status_code": 400,
  "success": false,
  "message": "Parameter short_url is required"
}
```

**401 Unauthorized** - Missing or invalid authentication:
```json
{
  "status_code": 401,
  "success": false,
  "message": "Unauthorized"
}
```

**422 Unprocessable Entity** - Validation failed:
```json
{
  "status_code": 422,
  "success": false,
  "message": "Validation failed: Url must use HTTPS"
}
```

**422 Unprocessable Entity** - Rate limit exceeded:
```json
{
  "status_code": 422,
  "success": false,
  "message": "You have reached the limit of short links, please upgrade to a paid plan to create more links."
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:3000/api/v1/short_urls/encode \
  -H "Content-Type: application/json" \
  -H "API-ACCESS-TOKEN: your_api_access_token" \
  -H "Authorization: Bearer your_session_token" \
  -d '{
    "short_url": {
      "url": "https://codesubmit.io/library/react"
    }
  }'
```

**Valid URL Examples:**
```json
✅ "https://example.com"
✅ "https://example.com/path/to/page"
✅ "https://example.com:8080/api"
✅ "https://example.com/page?param=value&other=test"
✅ "https://example.com/page#section"
✅ "https://subdomain.example.com/path"
```

**Invalid URL Examples:**
```json
❌ "http://example.com" (must be HTTPS)
❌ "https://localhost/test" (localhost blocked)
❌ "https://192.168.1.1/test" (private IP blocked)
❌ "https://127.0.0.1/test" (loopback blocked)
❌ "example.com" (missing protocol)
❌ "not-a-url" (invalid format)
```

---

## 🔓 Decode Endpoint

### Decode a Short URL

Retrieves the original URL from a short code. **This is a public endpoint** - no user authentication required!

**Endpoint:** `GET /api/v1/short_urls/decode/:code`

**Authentication Required:** API Access Token only (no user session needed)

**Headers:**
```http
API-ACCESS-TOKEN: your_api_access_token
```

**URL Parameters:**
- `code` (string, required) - The short code to decode (e.g., `GeAi9K`)

**Success Response (200 OK):**
```json
{
  "status_code": 200,
  "success": true,
  "message": "Link decoded successfully",
  "data": {
    "decoded_url": "https://codesubmit.io/library/react"
  }
}
```

**How It Works:**

1. User sends a GET request with the short code in the URL
2. System looks up the code in the database
3. If found, returns the original URL
4. If not found, returns a 404 error

**Key Features:**

- 🌐 **Public Access** - Anyone with the API token can decode any short URL
- 🔓 **No User Authentication** - Session token not required
- ⚡ **Fast Lookup** - Database indexed for instant retrieval
- 🔄 **Unlimited Decodes** - Same URL can be decoded multiple times
- 🔒 **Case Sensitive** - Codes are case-sensitive (`GeAi9K` ≠ `geai9k`)

**Error Response (404 Not Found):**
```json
{
  "status_code": 404,
  "success": false,
  "message": "This is a 404 error, which means you've entered an invalid URL"
}
```

**401 Unauthorized** - Missing or invalid API token:
```json
{
  "status_code": 401,
  "success": false,
  "message": "You dont have access to this resource"
}
```

**cURL Example:**
```bash
curl -X GET http://localhost:3000/api/v1/short_urls/decode/GeAi9K \
  -H "API-ACCESS-TOKEN: your_api_access_token"
```

**Browser Access:**

You can also access decode URLs directly in a browser:
```
http://localhost:3000/api/v1/short_urls/decode/GeAi9K
```

Just ensure the API-ACCESS-TOKEN is included (via browser extension or query parameter if configured).

---

## 🔄 Complete Workflow Example

Here's a complete example showing the full encode → decode workflow:

### Step 1: Login to Get Session Token

```bash
curl -X POST http://localhost:3000/api/v1/auth/sessions \
  -H "Content-Type: application/json" \
  -H "API-ACCESS-TOKEN: your_api_access_token" \
  -d '{
    "email_address": "demo@example.com",
    "password": "password123"
  }'
```

**Response:**
```json
{
  "status_code": 200,
  "success": true,
  "message": "Logged in successfully",
  "data": {
    "token": "xYz9KpQmN3vB7wL2jR8tF5hD1cS4gA6e",
    "user": {
      "id": 1,
      "email_address": "demo@example.com"
    }
  }
}
```

Save the token: `xYz9KpQmN3vB7wL2jR8tF5hD1cS4gA6e`

### Step 2: Encode a URL

```bash
curl -X POST http://localhost:3000/api/v1/short_urls/encode \
  -H "Content-Type: application/json" \
  -H "API-ACCESS-TOKEN: your_api_access_token" \
  -H "Authorization: Bearer xYz9KpQmN3vB7wL2jR8tF5hD1cS4gA6e" \
  -d '{
    "short_url": {
      "url": "https://codesubmit.io/library/react"
    }
  }'
```

**Response:**
```json
{
  "status_code": 200,
  "success": true,
  "message": "Link encoded successfully",
  "data": {
    "encoded_url": "http://localhost:3000/api/v1/short_urls/decode/GeAi9K"
  }
}
```

Save the code: `GeAi9K`

### Step 3: Decode the Short URL

```bash
curl -X GET http://localhost:3000/api/v1/short_urls/decode/GeAi9K \
  -H "API-ACCESS-TOKEN: your_api_access_token"
```

**Response:**
```json
{
  "status_code": 200,
  "success": true,
  "message": "Link decoded successfully",
  "data": {
    "decoded_url": "https://codesubmit.io/library/react"
  }
}
```

**Note:** The decode endpoint doesn't require the session token - anyone with the API access token can decode any short URL!

---

## 📊 Response Format

All API responses follow a consistent JSON structure:

### Success Response Structure

```json
{
  "status_code": 200,
  "success": true,
  "message": "Operation successful",
  "data": {
    // Response data here
  }
}
```

### Error Response Structure

```json
{
  "status_code": 400,
  "success": false,
  "message": "Error description here"
}
```

### HTTP Status Codes

| Code | Meaning | When It Occurs |
|------|---------|----------------|
| `200` | OK | Request succeeded |
| `400` | Bad Request | Invalid parameters or malformed request |
| `401` | Unauthorized | Missing or invalid authentication credentials |
| `404` | Not Found | Short URL code doesn't exist or route not found |
| `422` | Unprocessable Entity | Validation failed (invalid URL format, rate limit) |
| `500` | Internal Server Error | Unexpected server error |

---

## 🧪 Testing the API

### Using Postman

We provide a ready-to-use Postman collection with all endpoints pre-configured!

#### Import the Collection

1. **Download the collection:**
   - File: `ShortLink_API.postman_collection.json` (in the root directory)
   - Or [download from GitHub](https://github.com/your-username/short-link/blob/main/ShortLink_API.postman_collection.json)

2. **Import into Postman:**
   - Open Postman
   - Click "Import" button (top left)
   - Select the `ShortLink_API.postman_collection.json` file
   - Click "Import"

#### Configure Environment Variables

The collection includes these variables (automatically set):

| Variable | Description | Auto-Set |
|----------|-------------|----------|
| `base_url` | API base URL | ✅ Default: `http://localhost:3000` |
| `api_access_token` | Your API access token | ❌ **You must set this** |
| `session_token` | User session token | ✅ Auto-saved after login |
| `short_code` | Last encoded short code | ✅ Auto-saved after encode |

**To set your API access token:**
1. Click on the collection name
2. Go to "Variables" tab
3. Set `api_access_token` to your actual token (from Rails credentials)
4. Click "Save"

#### Collection Structure

The collection includes:

**1. Authentication**
- ✅ Login (Create Session) - Auto-saves session token

**2. Short URLs**
- ✅ Encode URL - Auto-saves short code
- ✅ Decode URL - Uses saved short code
- ✅ Decode URL - Not Found (test 404)

**3. Error Cases**
- ✅ Encode - Missing Authentication (401)
- ✅ Encode - Invalid URL (HTTP instead of HTTPS)
- ✅ Encode - Localhost URL (SSRF protection)
- ✅ Encode - Private IP (SSRF protection)

**4. Health Check**
- ✅ Server Status

#### Testing Workflow

1. **Update the `api_access_token` variable** with your actual token
2. **Run "Login"** - Session token is automatically saved
3. **Run "Encode URL"** - Short code is automatically saved
4. **Run "Decode URL"** - Uses the saved short code
5. **Explore error cases** to see validation in action

#### Automated Tests

The collection includes test scripts that:
- ✅ Automatically save tokens and codes
- ✅ Validate response structure
- ✅ Check status codes
- ✅ Extract data for next requests
