// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'myHealth';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get loginBtn => 'Sign In';

  @override
  String get registerBtn => 'Create Account';

  @override
  String get logout => 'Logout';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get home => 'Home';

  @override
  String get demographics => 'Patient Profile';

  @override
  String get questionnaires => 'Questionnaires';

  @override
  String get allergies => 'Allergies';

  @override
  String get medications => 'Medications';

  @override
  String get problems => 'Problem List';

  @override
  String get calendar => 'Calendar';

  @override
  String get settings => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get confirm => 'Confirm';

  @override
  String get deleteConfirm => 'Are you sure you want to delete this?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get name => 'Name';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get race => 'Race';

  @override
  String get ethnicity => 'Ethnicity';

  @override
  String get location => 'Location (City, Country)';

  @override
  String get motivationalQuote => 'Quote of the Day';

  @override
  String get weather => 'Weather';

  @override
  String get airQuality => 'Air Quality';

  @override
  String get temperature => 'Temperature';

  @override
  String get aqi => 'AQI';

  @override
  String get who5Title => 'WHO-5 Well-Being Index';

  @override
  String get who5Subtitle => 'Psychoemotional Questionnaire';

  @override
  String get who5History => 'WHO-5 History';

  @override
  String get framinghamTitle => 'Framingham Risk Score';

  @override
  String get framinghamSubtitle => 'Cardiovascular Risk Calculator';

  @override
  String get framinghamHistory => 'Framingham History';

  @override
  String get findRiscTitle => 'FINDRISC Score';

  @override
  String get findRiscSubtitle => 'Finnish Diabetes Risk Score';

  @override
  String get findRiscHistory => 'FINDRISC History';

  @override
  String get score => 'Score';

  @override
  String get riskLevel => 'Risk Level';

  @override
  String get date => 'Date';

  @override
  String get calculatedOn => 'Calculated on';

  @override
  String get allergen => 'Allergen';

  @override
  String get reaction => 'Reaction';

  @override
  String get severity => 'Severity';

  @override
  String get severityMild => 'Mild';

  @override
  String get severityModerate => 'Moderate';

  @override
  String get severitySevere => 'Severe';

  @override
  String get onsetDate => 'Onset Date';

  @override
  String get notes => 'Notes';

  @override
  String get addAllergy => 'Add Allergy';

  @override
  String get editAllergy => 'Edit Allergy';

  @override
  String get noAllergies => 'No allergies recorded';

  @override
  String get medicationName => 'Medication Name';

  @override
  String get dosage => 'Dosage';

  @override
  String get frequency => 'Frequency';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get currentMedications => 'Current Medications';

  @override
  String get medicationHistory => 'Medication History';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get editMedication => 'Edit Medication';

  @override
  String get noMedications => 'No medications recorded';

  @override
  String get icd10Code => 'ICD-10 Code';

  @override
  String get diagnosis => 'Diagnosis';

  @override
  String get status => 'Status';

  @override
  String get statusActive => 'Active';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get statusChronic => 'Chronic';

  @override
  String get addProblem => 'Add Problem';

  @override
  String get editProblem => 'Edit Problem';

  @override
  String get noProblems => 'No problems recorded';

  @override
  String get searchIcd => 'Search ICD-10 code or diagnosis...';

  @override
  String get calendarTitle => 'Health Calendar';

  @override
  String get noEvents => 'No events on this day';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get greek => 'Greek';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get loginError => 'Invalid email or password';

  @override
  String get emailTaken => 'Email already registered';

  @override
  String get age => 'Age';

  @override
  String get totalCholesterol => 'Total Cholesterol (mg/dL)';

  @override
  String get hdlCholesterol => 'HDL Cholesterol (mg/dL)';

  @override
  String get systolicBP => 'Systolic Blood Pressure (mmHg)';

  @override
  String get bpTreated => 'On Blood Pressure Treatment';

  @override
  String get smoker => 'Current Smoker';

  @override
  String get calculate => 'Calculate';

  @override
  String get yourScore => 'Your Score';

  @override
  String get riskPercent => '10-Year CVD Risk';

  @override
  String get bmi => 'BMI (kg/m²)';

  @override
  String get waistCircumference => 'Waist Circumference (cm)';

  @override
  String get physicalActivity => 'Physical Activity';

  @override
  String get eatVegetables => 'Daily vegetables/fruits';

  @override
  String get hypertension => 'Hypertension';

  @override
  String get highBloodGlucose => 'High Blood Glucose';

  @override
  String get familyDiabetes => 'Family History of Diabetes';

  @override
  String get low => 'Low';

  @override
  String get slightlyElevated => 'Slightly Elevated';

  @override
  String get moderate => 'Moderate';

  @override
  String get high => 'High';

  @override
  String get veryHigh => 'Very High';

  @override
  String get heraklion => 'Heraklion, Greece';

  @override
  String get noDemographics => 'No profile found. Please fill in your details.';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get viewHistory => 'View History';

  @override
  String get history => 'History';

  @override
  String get noHistory => 'No history available';
}
