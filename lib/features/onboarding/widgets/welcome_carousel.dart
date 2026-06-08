import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class TourSlide {
  final String emoji;
  final Color  color;
  final String title;
  final String desc;
  /// Nota opcional (datos + fuente) en letra más pequeña debajo de la descripción.
  final String? note;
  const TourSlide(this.emoji, this.color, this.title, this.desc, {this.note});
}

/// Tour de bienvenida para el CLIENTE (consumidor).
Future<void> showWelcomeCarousel(BuildContext context) {
  final l = AppLocalizations.of(context);
  final slides = <TourSlide>[
    TourSlide('🎉', const Color(0xFFF26522), l.tour1Title, l.tour1Desc),
    TourSlide('📍', const Color(0xFF00838F), l.tour2Title, l.tour2Desc),
    TourSlide('⚡', const Color(0xFFE8302A), l.tour3Title, l.tour3Desc),
    TourSlide('🎟️', const Color(0xFF6A4CAF), l.tour4Title, l.tour4Desc),
    TourSlide('⭐', const Color(0xFFE8A700), l.tour5Title, l.tour5Desc),
  ];
  return _push(context, slides);
}

/// Tour para cuando un usuario se convierte en DUEÑO de negocio.
Future<void> showOwnerTour(BuildContext context) {
  final l = AppLocalizations.of(context);
  final slides = <TourSlide>[
    TourSlide('🤝', const Color(0xFFF26522), l.ownerTour1Title, l.ownerTour1Desc),
    TourSlide('🎁', const Color(0xFFE8A700), l.ownerTour6Title, l.ownerTour6Desc,
        note: l.ownerTour6Note),
    TourSlide('🏷️', const Color(0xFFE8302A), l.ownerTour2Title, l.ownerTour2Desc),
    TourSlide('📷', const Color(0xFF00838F), l.ownerTour3Title, l.ownerTour3Desc),
    TourSlide('📣', const Color(0xFF6A4CAF), l.ownerTour4Title, l.ownerTour4Desc),
    TourSlide('📊', const Color(0xFF2E7D32), l.ownerTour5Title, l.ownerTour5Desc),
  ];
  return _push(context, slides);
}

Future<void> _push(BuildContext context, List<TourSlide> slides) {
  return Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => TourCarousel(slides: slides),
    ),
  );
}

class TourCarousel extends StatefulWidget {
  final List<TourSlide> slides;
  const TourCarousel({super.key, required this.slides});

  @override
  State<TourCarousel> createState() => _TourCarouselState();
}

class _TourCarouselState extends State<TourCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page >= widget.slides.length - 1) {
      Navigator.of(context).maybePop();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final slides = widget.slides;
    final isLast = _page == slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: Text(l.tourSkip,
                      style: TextStyle(color: Colors.grey.shade600)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: slides.length,
                itemBuilder: (_, i) {
                  final s = slides[i];
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 120, height: 120,
                            decoration: BoxDecoration(
                              color: s.color.withAlpha(28),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(s.emoji,
                                style: const TextStyle(fontSize: 60)),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            s.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            s.desc,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15, height: 1.4,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          if (s.note != null) ...[
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                s.note!,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 11.5, height: 1.45,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    isLast ? l.tourStart : l.tourNext,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
