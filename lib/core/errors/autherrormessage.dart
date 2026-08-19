String getAuthErrorMessage(String code) {
  switch (code) {
    case 'user-not-found':
      return 'No user found with this email address.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'email-already-in-use':
      return 'An account already exists for this email.';
    case 'invalid-email':
      return 'The email address is invalid.';
    case 'weak-password':
      return 'The password is too weak. Please use at least 6 characters.';
    default:
      return 'Authentication error ($code). Please try again.';
  }
}