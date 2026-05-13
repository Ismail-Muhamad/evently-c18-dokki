class OnboardingModel {
  final String lightImage;
  final String darkImage;
  final String enTitle;
  final String arTitle;
  final String enDescription;
  final String arDescription;

  const OnboardingModel({
    required this.lightImage,
    required this.darkImage,
    required this.enTitle,
    required this.arTitle,
    required this.enDescription,
    required this.arDescription,
  });

  String imagePath(bool isDark) => isDark ? darkImage : lightImage;

  String title(bool isEn) => isEn ? enTitle : arTitle;

  String description(bool isEn) => isEn ? enDescription : arDescription;
}

const List<OnboardingModel> onboardingItems = [
  OnboardingModel(
    lightImage: 'assets/images/onboarding_1_light.png',
    darkImage: 'assets/images/onboarding_1_dark.png',
    enTitle: 'Find Events That Inspire You',
    arTitle: 'اكتشف فعاليات تلهمك',
    enDescription:
        "Dive into a world of events crafted to fit your unique interests. Whether you're into live music, art workshops, professional networking, or simply discovering new experiences, we have something for everyone. Our curated recommendations will help you explore, connect, and make the most of every opportunity around you.",
    arDescription:
        'اكتشف عالما من الفعاليات المصممة لتناسب اهتماماتك. سواء كنت تحب الموسيقى الحية أو ورش الفن أو networking المهني أو التجارب الجديدة، ستجد ما يناسبك. ترشيحاتنا تساعدك على الاستكشاف والتواصل والاستفادة من كل فرصة حولك.',
  ),
  OnboardingModel(
    lightImage: 'assets/images/onboarding_2_light.png',
    darkImage: 'assets/images/onboarding_2_dark.png',
    enTitle: 'Effortless Event Planning',
    arTitle: 'تنظيم فعاليات بسهولة',
    enDescription:
        "Take the hassle out of organizing events with our all-in-one planning tools. From setting up invites and managing RSVPs to scheduling reminders and coordinating details, we've got you covered. Plan with ease and focus on what matters - creating an unforgettable experience for you and your guests.",
    arDescription:
        'نظم فعالياتك بسهولة باستخدام أدوات التخطيط المتكاملة. من إنشاء الدعوات وإدارة الحضور إلى جدولة التذكيرات وتنسيق التفاصيل، كل شيء في مكان واحد لتصنع تجربة لا تنسى لك ولضيوفك.',
  ),
  OnboardingModel(
    lightImage: 'assets/images/onboarding_3_light.png',
    darkImage: 'assets/images/onboarding_3_dark.png',
    enTitle: 'Connect with Friends & Share Moments',
    arTitle: 'تواصل مع أصدقائك وشارك اللحظات',
    enDescription:
        'Make every event memorable by sharing the experience with others. Our platform lets you invite friends, keep everyone in the loop, and celebrate moments together. Capture and share the excitement with your network, so you can relive the highlights and cherish the memories.',
    arDescription:
        'اجعل كل فعالية ذكرى مميزة من خلال مشاركتها مع الآخرين. يمكنك دعوة الأصدقاء وإبقاء الجميع على اطلاع والاحتفال باللحظات معا. شارك الحماس مع شبكتك واسترجع أجمل الذكريات.',
  ),
];
