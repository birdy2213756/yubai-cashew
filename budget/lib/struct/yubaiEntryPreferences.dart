/// Apply the new default once; a later user choice to ask for a name survives.
bool migrateYubaiEntryPreferences(Map<String, dynamic> settings) {
  final version = settings['yubaiEntryFlowVersion'];
  if (version is num && version >= 1) return false;
  settings['askForTransactionTitle'] = false;
  settings['yubaiEntryFlowVersion'] = 1;
  return true;
}
