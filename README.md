# myHealth\_App-







Design and develop\* a multilingual mobile health application in Flutter/Dart for patients. The application must support authentication, retrieval of one motivational message at each login, implementation of a short psychoemotional questionnaire, implementation of the Framingham score and one additional clinical risk score, storage and visualization of user-entered health data, graphical monitoring of scores over time, environmental data retrieval through a free API, management of allergies, medication, and a problem list using ICD terminology, and a calendar view integrating all recorded health events. The app must support English by default and one additional language.

\*You can use AI assistants if you’d like.

App modules

1\. Login

The app must include a login page.

•

email/username + password login form

•

basic validation

2\. Patient demographics

Create a form where the patient will store the basic demographics age, gender, race, ethnicity, name, birthday, location (city – country).

3\. Motivational message API

At every successful login, the app must call an API and retrieve one motivational message, which is then displayed on the home page as a card. e.g. https://zenquotes.io/api/random

4\. Weather and Pollution

Use the following open APIs to retrieve the temperature and air quality index for Heraklion every time the user logins and display it always in your app.

5\. Psychoemotional questionnaire

The app must implement the short psychoemotional questionnaire WHO-5 Well-Being Index. The app must calculate the final score and store it in the local database.

6\. Framingham score calculator

The app must implement a Framingham cardiovascular risk score calculator and store the score in the local database along with the date of application.

7\. Finnish Diabetes Risk Score calculator

The app must implement the FINDRISC (Finnish Diabetes Risk Score)and store the score in the local database along with the date of application.

8\. Allergies module

The app must include an Allergies section. Each allergy record should contain:

•

allergen name

•

reaction description

•

severity

•

onset date, if known

•

notes

The user must be able to:

•

add

•

delete

•

view all allergies

9\. Medication module

The app must include a Medication section. Each medication record should contain:

•

medication name

•

dosage

•

frequency

•

start date

•

end date or ongoing flag

•

notes

The app should support:

•

current medication list

•

medication history

•

optional reminders as bonus functionality

10\. Problem List using ICD terminology

The app must include a Problem List module using ICD-9 (or ICD-10) terminology.

Each problem entry should contain:

•

ICD-9 or ICD-10 code

•

diagnosis/problem title

•

status

•

date added

•

notes

The app must support searchable ICD-9 or ICD-10 list or local lookup

11\. Calendar module

The app must include a calendar where the information from the above modules becomes visible in date-based form. The calendar should display events such as:

•

questionnaire completion

•

risk score calculation

•

medication

•

allergy

•

problem list

12\. Multilingual support

The app must be multilingual. Mandatory language support:

•

English as the default language

•

one additional language of the team’s choice



