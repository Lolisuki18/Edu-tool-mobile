class RolePermissions {
  // permission strings used across the app
  // e.g. 'requirements:view', 'requirements:add', 'requirements:export', 'reports:create'
  static final Map<String, Set<String>> _perms = {
    'Admin': {
      '*', // wildcard means all permissions
    },
    'Lecturer': {
      'home:view',
      'requirements:view',
      'reports:view',
      'reports:create',
      'profile:view',
    },
    'Team Leader': {
      'home:view',
      'requirements:view',
      'requirements:add',
      'requirements:export',
      'commits:view',
      'reports:view',
      'profile:view',
    },
    'Member': {
      'home:view',
      'commits:view',
      'requirements:export',
      'profile:view',
    },
  };

  static bool isAllowed(String? role, String permission) {
    final r = role ?? 'Member';
    final perms = _perms[r];
    if (perms == null) return false;
    if (perms.contains('*')) return true;
    return perms.contains(permission);
  }
}
