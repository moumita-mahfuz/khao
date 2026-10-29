/// Scroll targets for nav links and buttons.
enum KhaoSection { signature, menu, daypart, visit }

typedef SectionNavigator = void Function(KhaoSection section);

/// Sections temporarily taken off the page. Their nav links are hidden too.
/// Remove an entry to bring the section back.
const hiddenSections = {KhaoSection.signature};

extension KhaoSectionVisibility on KhaoSection {
  bool get isVisible => !hiddenSections.contains(this);
}
