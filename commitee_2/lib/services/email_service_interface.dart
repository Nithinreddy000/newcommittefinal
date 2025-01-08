abstract class EmailServiceInterface {
  Future<bool> sendCredentials({
    required String email,
    required String username,
    required String password,
    required String name,
    required String flatNumber,
    required String role,
    required String contactNumber,
  });

  Future<void> sendWelcomeEmail({
    required String toName,
    required String toEmail,
  });
}
