import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/member.dart';
import '../../../services/email_service.dart';
import '../../../services/auth_service.dart';
import '../../../providers/member_provider.dart';

class ManageMembersScreen extends StatelessWidget {
  const ManageMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _showAddMemberDialog(context),
              child: const Text('Add New Member'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<MemberProvider>(
                builder: (context, provider, child) {
                  if (provider.members.isEmpty) {
                    return const Center(
                      child: Text('No members added yet'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: provider.members.length,
                    itemBuilder: (context, index) {
                      final member = provider.members[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(member.name[0]),
                          ),
                          title: Text(member.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Role: ${member.role}'),
                              Text('Email: ${member.email}'),
                              if (member.flatNumber != null) 
                                Text('Flat: ${member.flatNumber}'),
                              if (member.idNumber != null) 
                                Text('ID: ${member.idNumber}'),
                              Text('Contact: ${member.contactNumber}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => provider.removeMember(member.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final numberController = TextEditingController();
    final contactController = TextEditingController();
    String selectedRole = 'resident';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Member'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (!value!.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'resident', child: Text('Resident')),
                      DropdownMenuItem(value: 'security', child: Text('Security')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                        numberController.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: numberController,
                    decoration: InputDecoration(
                      labelText: selectedRole == 'resident' ? 'Flat Number' : 'Security ID',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Generate password
                  final password = selectedRole == 'resident' 
                      ? 'RES${numberController.text}${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
                      : 'SEC${numberController.text}${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

                  // Add member
                  final provider = context.read<MemberProvider>();
                  await provider.addMember(
                    name: nameController.text,
                    email: emailController.text,
                    flatNumber: selectedRole == 'resident' ? numberController.text : null,
                    idNumber: selectedRole == 'security' ? numberController.text : null,
                    contactNumber: contactController.text,
                    role: selectedRole,
                  );

                  // Register user
                  context.read<AuthService>().registerUser(
                    emailController.text,
                    password,
                    selectedRole,
                    nameController.text,
                    selectedRole == 'resident' ? numberController.text : null,
                    selectedRole == 'security' ? numberController.text : null,
                  );

                  // Send welcome email
                  final emailSent = await EmailService().sendCredentials(
                    email: emailController.text,
                    username: emailController.text,
                    password: password,
                    name: nameController.text,
                    flatNumber: numberController.text,
                    role: selectedRole,
                    contactNumber: contactController.text,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          emailSent 
                            ? 'Member added successfully. Credentials sent via email.'
                            : 'Member added successfully but failed to send email.',
                        ),
                      ),
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
} 