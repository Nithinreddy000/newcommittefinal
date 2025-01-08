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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Members Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Residents'),
              Tab(text: 'Admins'),
              Tab(text: 'Security'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ResidentsTab(),
            _AdminsTab(),
            _SecurityTab(),
          ],
        ),
      ),
    );
  }
}

class _ResidentsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _showAddMemberDialog(context),
            child: const Text('Add New Resident'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<MemberProvider>(
              builder: (context, provider, child) {
                final residents = provider.members.where((m) => m.role == 'resident').toList();
                
                if (residents.isEmpty) {
                  return const Center(
                    child: Text('No residents added yet'),
                  );
                }
                
                return ListView.builder(
                  itemCount: residents.length,
                  itemBuilder: (context, index) {
                    final member = residents[index];
                    return _buildMemberCard(context, member, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _showAddMemberDialog(context, isAdmin: true),
            child: const Text('Add New Admin'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<MemberProvider>(
              builder: (context, provider, child) {
                final admins = provider.members.where((m) => m.role == 'admin').toList();
                
                if (admins.isEmpty) {
                  return const Center(
                    child: Text('No admins added yet'),
                  );
                }
                
                return ListView.builder(
                  itemCount: admins.length,
                  itemBuilder: (context, index) {
                    final member = admins[index];
                    return _buildMemberCard(context, member, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _showAddMemberDialog(context, isSecurity: true),
            child: const Text('Add New Security Staff'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<MemberProvider>(
              builder: (context, provider, child) {
                final security = provider.members.where((m) => m.role == 'security').toList();
                
                if (security.isEmpty) {
                  return const Center(
                    child: Text('No security staff added yet'),
                  );
                }
                
                return ListView.builder(
                  itemCount: security.length,
                  itemBuilder: (context, index) {
                    final member = security[index];
                    return _buildMemberCard(context, member, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void _showCredentialsDialog(BuildContext context, String name, String email, String password, {Member? member}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Member Credentials'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$name has been ${member != null ? 'sent their' : 'added with the following'} credentials:'),
          const SizedBox(height: 8),
          const Text(
            'Login Credentials:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Email: $email'),
          SelectableText(
            'Password: $password',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Note: Please share these credentials securely with the member.',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final provider = context.read<MemberProvider>();
            final success = await provider.resendCredentials(member!);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success 
                    ? 'Credentials sent successfully!' 
                    : 'Failed to send credentials. Please try again.'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            }
          },
          child: const Text('Resend Email'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Widget _buildMemberCard(BuildContext context, Member member, MemberProvider provider) {
  return Card(
    child: ListTile(
      title: Text(member.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email: ${member.email}'),
          if (member.role == 'resident')
            Text('Flat: ${member.flatNumber ?? 'N/A'}')
          else
            Text('ID: ${member.idNumber ?? 'N/A'}'),
          Text('Contact: ${member.contactNumber}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.email_outlined),
            tooltip: 'Resend Credentials',
            onPressed: () async {
              final success = await provider.resendCredentials(member);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                      ? 'Credentials sent successfully!' 
                      : 'Failed to send credentials. Please try again.'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditMemberDialog(context, member),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmationDialog(context, member),
          ),
        ],
      ),
    ),
  );
}

void _showAddMemberDialog(BuildContext context, {bool isAdmin = false, bool isSecurity = false}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final numberController = TextEditingController();

  String getTitle() {
    if (isAdmin) return 'Add New Admin';
    if (isSecurity) return 'Add New Security Staff';
    return 'Add New Resident';
  }

  String getNumberFieldLabel() {
    if (isAdmin) return 'Admin ID';
    if (isSecurity) return 'Security ID';
    return 'Flat Number';
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(getTitle()),
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
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter an email';
                  }
                  if (!value!.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: numberController,
                decoration: InputDecoration(
                  labelText: getNumberFieldLabel(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter ${getNumberFieldLabel()}' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a contact number' : null,
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
            if (formKey.currentState?.validate() ?? false) {
              final provider = context.read<MemberProvider>();
              final (success, password) = await provider.addMember(
                name: nameController.text,
                email: emailController.text,
                contactNumber: contactController.text,
                flatNumber: (!isAdmin && !isSecurity) ? numberController.text : null,
                idNumber: (isAdmin || isSecurity) ? numberController.text : null,
                role: isAdmin ? 'admin' : (isSecurity ? 'security' : 'resident'),
              );

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  _showCredentialsDialog(
                    context,
                    nameController.text,
                    emailController.text,
                    password,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to add member. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}

void _showEditMemberDialog(BuildContext context, Member member) {
  final nameController = TextEditingController(text: member.name);
  final emailController = TextEditingController(text: member.email);
  final numberController = TextEditingController(
    text: member.flatNumber ?? member.idNumber ?? '',
  );
  final contactController = TextEditingController(text: member.contactNumber);
  String selectedRole = member.role;
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Edit Member'),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
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
                    DropdownMenuItem(
                      value: 'resident',
                      child: Text('Resident'),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Admin'),
                    ),
                    DropdownMenuItem(
                      value: 'security',
                      child: Text('Security'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (selectedRole == 'resident')
                  TextFormField(
                    controller: numberController,
                    decoration: const InputDecoration(
                      labelText: 'Flat Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a flat number';
                      }
                      return null;
                    },
                  )
                else if (selectedRole == 'admin')
                  TextFormField(
                    controller: numberController,
                    decoration: const InputDecoration(
                      labelText: 'Admin ID',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an admin ID';
                      }
                      return null;
                    },
                  )
                else
                  TextFormField(
                    controller: numberController,
                    decoration: const InputDecoration(
                      labelText: 'Security ID',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a security ID';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a contact number';
                    }
                    return null;
                  },
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
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final provider = context.read<MemberProvider>();
                provider.updateMember(
                  Member(
                    id: member.id,
                    name: nameController.text,
                    email: emailController.text,
                    flatNumber: selectedRole == 'resident' ? numberController.text : null,
                    idNumber: selectedRole == 'admin' || selectedRole == 'security' ? numberController.text : null,
                    contactNumber: contactController.text,
                    role: selectedRole,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    ),
  );
}

void _showDeleteConfirmationDialog(BuildContext context, Member member) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Member'),
      content: Text('Are you sure you want to delete ${member.name}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final provider = context.read<MemberProvider>();
            provider.removeMember(member.id);
            Navigator.pop(context);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}