# Password Reset System API

A secure password reset management system built with Ruby on Rails 7.0.8, MySQL 8, and JWT authentication.

## Requirements

- Ruby 3.2.0
- Rails 7.2.2
- MySQL 8.0+
- Node.js
-Tailwind CSS


## Setup

1. Clone the repository
2. Install dependencies:


I want an application for reseting password,what will be happening is that a user will will call helpdesk
asking for password reset and then helpdesk officer will ask for firstname,username,dateofbirth,location.

Once all the user info have been corrected the the helpdesk officer will login into the password reset system. Enter the details and then deatails will saved in the transaction table.
Then using firstname,lastname, and date of birth  the system will create a code and also a bar code.
Both the code and barcode can should be displayed on the on page and the sent to the officer who 
requested password change via sms or whatsapp. The barcode and the generated encrypted code  they should have 
24 hours before expiration.

I want to use the transactions table to track how many passwords have been requested for change.
it should be a ruby on rails application, having mysql database.
It should have table for storing users(id,firstname,lastname,password) and Transaction table
Create a single html page for the helpdesk officer with two section, the right section should contain infomation about the application and right section should contain the login form, and if if the user click on sign up button the the form should switch from login to signup.

Use AES-256 encryption for the reset codes 
Code format: firstname,lastname,date of birth, sex,Expiration time
Ensure the resulting code is human-readable (alphanumeric) 

make this reset application super modern,beautiful, add icons animations and make the app look like 1,000,000 dollar application it should just be perfect like wow!!

