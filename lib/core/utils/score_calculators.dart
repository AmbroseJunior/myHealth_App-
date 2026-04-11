/// WHO-5 Well-Being Index
/// Each question scored 0-5, total 0-25 (multiply by 4 for %)
int who5TotalScore(List<int> responses) {
  return responses.fold(0, (a, b) => a + b);
}

String who5Category(int rawScore) {
  final pct = rawScore * 4;
  if (pct <= 28) return 'Poor well-being (possible depression)';
  if (pct <= 50) return 'Below average well-being';
  if (pct <= 72) return 'Average well-being';
  return 'Good well-being';
}

/// Framingham 10-year CVD Risk Score (2008 point system)
double framinghamRiskScore({
  required int age,
  required String gender, // 'male' or 'female'
  required double totalChol,
  required double hdlChol,
  required int systolicBP,
  required bool isBpTreated,
  required bool isSmoker,
}) {
  int points = 0;

  if (gender == 'male') {
    // Age
    if (age < 35) points += -9;
    else if (age < 40) points += -4;
    else if (age < 45) points += 0;
    else if (age < 50) points += 3;
    else if (age < 55) points += 6;
    else if (age < 60) points += 8;
    else if (age < 65) points += 10;
    else if (age < 70) points += 11;
    else if (age < 75) points += 12;
    else points += 13;

    // Total cholesterol
    if (totalChol < 160) points += 0;
    else if (totalChol < 200) points += 4;
    else if (totalChol < 240) points += 7;
    else if (totalChol < 280) points += 9;
    else points += 11;

    // HDL
    if (hdlChol >= 60) points -= 1;
    else if (hdlChol >= 50) points += 0;
    else if (hdlChol >= 40) points += 1;
    else points += 2;

    // Systolic BP
    if (!isBpTreated) {
      if (systolicBP < 120) points += 0;
      else if (systolicBP < 130) points += 0;
      else if (systolicBP < 140) points += 1;
      else if (systolicBP < 160) points += 1;
      else points += 2;
    } else {
      if (systolicBP < 120) points += 0;
      else if (systolicBP < 130) points += 2;
      else if (systolicBP < 140) points += 2;
      else if (systolicBP < 160) points += 2;
      else points += 3;
    }

    // Smoking
    if (isSmoker) points += 4;
  } else {
    // Female
    if (age < 35) points += -7;
    else if (age < 40) points += -3;
    else if (age < 45) points += 0;
    else if (age < 50) points += 3;
    else if (age < 55) points += 6;
    else if (age < 60) points += 8;
    else if (age < 65) points += 10;
    else if (age < 70) points += 12;
    else if (age < 75) points += 14;
    else points += 16;

    // Total cholesterol
    if (totalChol < 160) points += 0;
    else if (totalChol < 200) points += 4;
    else if (totalChol < 240) points += 8;
    else if (totalChol < 280) points += 11;
    else points += 13;

    // HDL
    if (hdlChol >= 60) points -= 1;
    else if (hdlChol >= 50) points += 0;
    else if (hdlChol >= 40) points += 1;
    else points += 2;

    // Systolic BP
    if (!isBpTreated) {
      if (systolicBP < 120) points += 0;
      else if (systolicBP < 130) points += 1;
      else if (systolicBP < 140) points += 2;
      else if (systolicBP < 160) points += 3;
      else points += 4;
    } else {
      if (systolicBP < 120) points += 0;
      else if (systolicBP < 130) points += 3;
      else if (systolicBP < 140) points += 4;
      else if (systolicBP < 160) points += 5;
      else points += 6;
    }

    // Smoking
    if (isSmoker) points += 3;
  }

  // Convert points to % risk
  final riskTableMale = {
    -3: 1.0, -2: 1.1, -1: 1.4, 0: 1.6, 1: 1.9, 2: 2.3, 3: 2.8,
    4: 3.3, 5: 3.9, 6: 4.7, 7: 5.6, 8: 6.7, 9: 7.9, 10: 9.4,
    11: 11.2, 12: 13.2, 13: 15.6, 14: 18.4, 15: 21.6, 16: 25.3, 17: 29.4,
  };
  final riskTableFemale = {
    -2: 1.0, -1: 1.0, 0: 1.0, 1: 1.0, 2: 1.3, 3: 1.6, 4: 1.9, 5: 2.4,
    6: 3.0, 7: 3.7, 8: 4.5, 9: 5.6, 10: 6.9, 11: 8.4, 12: 10.3, 13: 12.5,
    14: 15.2, 15: 18.4, 16: 22.3, 17: 26.9,
  };

  final table = gender == 'male' ? riskTableMale : riskTableFemale;
  if (points <= table.keys.first) return table[table.keys.first]!;
  if (points >= table.keys.last) return table[table.keys.last]!;
  return table[points] ?? table.entries.lastWhere((e) => e.key <= points).value;
}

String framinghamRiskCategory(double riskPercent) {
  if (riskPercent < 10) return 'Low (<10%)';
  if (riskPercent < 20) return 'Intermediate (10–20%)';
  return 'High (≥20%)';
}

/// FINDRISC — Finnish Diabetes Risk Score
int findRiscScore({
  required int ageScore,         // 0,2,3,4
  required int bmiScore,         // 0,1,3
  required int waistScore,       // 0,3,4
  required int physicalActivityScore, // 0,2
  required int vegetableScore,   // 0,1
  required int hypertensionScore, // 0,2
  required int hyperglycemiaScore, // 0,5
  required int familyScore,      // 0,3,5
}) {
  return ageScore + bmiScore + waistScore + physicalActivityScore +
      vegetableScore + hypertensionScore + hyperglycemiaScore + familyScore;
}

String findRiscCategory(int score) {
  if (score <= 6) return 'low';
  if (score <= 11) return 'slightly elevated';
  if (score <= 14) return 'moderate';
  if (score <= 20) return 'high';
  return 'very high';
}

String findRiscDescription(int score) {
  final cat = findRiscCategory(score);
  switch (cat) {
    case 'low': return 'Low risk (~1% over 10 years)';
    case 'slightly elevated': return 'Slightly elevated risk (~4%)';
    case 'moderate': return 'Moderate risk (~17%)';
    case 'high': return 'High risk (~33%)';
    default: return 'Very high risk (~50%)';
  }
}

