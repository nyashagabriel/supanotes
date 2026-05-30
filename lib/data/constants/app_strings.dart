class AppStrings {
  AppStrings._();

  // Core
  static const String appName = 'Supanotes';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String unknownUser = 'Unknown User';
  
  // Auth Headers
  static const String welcomeBack = 'Welcome Back';
  static const String welcomeNew = 'Create an Account';
  static const String subtitleSignIn = 'Log in to access your secure workspace.';
  static const String subtitleSignUp = 'Register to start building your knowledge graph.';
  
  // Auth Actions
  static const String signInLabel = 'Sign In';
  static const String signUpLabel = 'Sign Up';
  static const String signOutLabel = 'Sign Out';
  
  // Errors & Fallbacks
  static const String authFailed = 'Authentication failed. Please check your credentials.';
  static const String signOutFailed = 'There was an issue logging out.';
  static const String errorLoading = 'Error loading data.';
  static const String noNotesFound = 'No notes found.';
  static const String synthesisFailed = 'Synthesis failed.';
  
  // Disclaimers
  static const String securityDisclaimer = 'Security Notice: AI Summaries are processed via third-party systems. Do not include highly sensitive or personally identifiable information in your notes.';

  // Workspace
  static const String workspace = 'Workspace';
  static const String selected = 'Selected';
  static const String searchHint = 'Search notes, tags...';
  static const String deleteSelected = 'Delete Selected';
  static const String synthesizeThoughts = 'Synthesize Thoughts';
  static const String macroSynthesis = 'Macro-Synthesis';

  // Profile & Settings
  static const String profileTitle = 'Profile & Settings';
  static const String loggedInAs = 'Logged in as';
  static const String themePreference = 'Theme Preference';
  static const String darkMode = 'Dark Mode';
  static const String databaseConnection = 'Database Connection';
  static const String connected = 'Connected';
}