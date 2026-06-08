import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get languageAuto => 'Automatisch (Gerät)';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get explore => 'Entdecken';

  @override
  String get favTitle => 'Meine Favoriten';

  @override
  String get favTabPromos => 'Angebote';

  @override
  String get favTabEstablishments => 'Orte';

  @override
  String get favEmptyPromosTitle => 'Du hast noch keine Lieblingsangebote';

  @override
  String get favEmptyPromosSubtitle => 'Tippe bei einem Angebot auf das Herz,\num es hier zu speichern';

  @override
  String get favEmptyEstTitle => 'Du hast noch keine Lieblingsorte';

  @override
  String get favEmptyEstSubtitle => 'Öffne einen Ort und tippe auf das Herz,\num ihn hier zu speichern';

  @override
  String get removeFromFavorites => 'Aus Favoriten entfernen';

  @override
  String get loginWelcome => 'Willkommen bei Promofy';

  @override
  String get loginSubtitle => 'Entdecke Angebote in deiner Nähe';

  @override
  String get loginContinueGoogle => 'Mit Google fortfahren';

  @override
  String get loginOr => 'oder';

  @override
  String get loginEmailLabel => 'E-Mail';

  @override
  String get loginEmailEmpty => 'Gib deine E-Mail ein';

  @override
  String get loginEmailInvalid => 'Ungültige E-Mail';

  @override
  String get loginPasswordLabel => 'Passwort';

  @override
  String get loginPasswordEmpty => 'Gib dein Passwort ein';

  @override
  String get loginPasswordMinLength => 'Mindestens 6 Zeichen';

  @override
  String get loginForgotPassword => 'Passwort vergessen?';

  @override
  String get loginSignInButton => 'Anmelden';

  @override
  String get loginSignUpButton => 'Konto erstellen';

  @override
  String get loginNoAccount => 'Noch kein Konto? ';

  @override
  String get loginHaveAccount => 'Bereits ein Konto? ';

  @override
  String get loginSignUpLink => 'Registrieren';

  @override
  String get loginSignInLink => 'Anmelden';

  @override
  String get loginResetInvalidEmail => 'Gib eine gültige E-Mail ein.';

  @override
  String get loginResetTitle => 'Passwort zurücksetzen';

  @override
  String get loginResetDone => 'Fertig';

  @override
  String get loginResetCancel => 'Abbrechen';

  @override
  String get loginResetSend => 'Senden';

  @override
  String get loginResetDescription => 'Wir senden dir einen Link zum Zurücksetzen deines Passworts.';

  @override
  String get loginResetEmailHint => 'du@email.com';

  @override
  String get loginResetSuccessTitle => 'E-Mail gesendet!';

  @override
  String get loginResetSuccessBody => 'Überprüfe deinen Posteingang und folge den Anweisungen.';

  @override
  String get loginResetSpamHint => 'Falls sie nicht in wenigen Minuten ankommt, prüfe deinen Spam-Ordner.';

  @override
  String get onboardingTitle => 'Vervollständige dein Profil';

  @override
  String get onboardingExit => 'Beenden';

  @override
  String get onboardingHeading => 'Erzähl uns von dir';

  @override
  String get onboardingAdultOnlyNotice => 'Promofy ist ausschließlich für Personen ab 18 Jahren';

  @override
  String get onboardingNameQuestion => 'Wie heißt du?';

  @override
  String get onboardingNameHint => 'Dein vollständiger Name';

  @override
  String get onboardingNameRequired => 'Gib deinen Namen ein';

  @override
  String get onboardingBirthQuestion => 'Wann bist du geboren?';

  @override
  String get onboardingSelectBirthDate => 'Wähle dein Geburtsdatum';

  @override
  String get onboardingGenderQuestion => 'Was ist dein Geschlecht?';

  @override
  String get onboardingGenderMale => 'Männlich';

  @override
  String get onboardingGenderFemale => 'Weiblich';

  @override
  String get onboardingGenderPreferNot => 'Keine Angabe';

  @override
  String get onboardingSubmit => 'Mein Profil vervollständigen';

  @override
  String get onboardingMustBeAdult => 'Du musst über 18 Jahre alt sein';

  @override
  String get onboardingConfirm => 'Bestätigen';

  @override
  String get onboardingCancel => 'Abbrechen';

  @override
  String get onboardingMustBeAdultToUse => 'Du musst über 18 Jahre alt sein, um Promofy zu nutzen';

  @override
  String get onboardingSelectGender => 'Wähle dein Geschlecht';

  @override
  String get resetPwdAppBarTitle => 'Neues Passwort';

  @override
  String get resetPwdUpdateError => 'Das Passwort konnte nicht aktualisiert werden.';

  @override
  String get resetPwdSuccessTitle => 'Passwort aktualisiert!';

  @override
  String get resetPwdSuccessSubtitle => 'Du kannst dich jetzt\nmit deinem neuen Passwort anmelden.';

  @override
  String get resetPwdGoHome => 'Zur Startseite';

  @override
  String get resetPwdFormTitle => 'Erstelle dein neues Passwort';

  @override
  String get resetPwdFormHint => 'Es muss mindestens 6 Zeichen lang sein.';

  @override
  String get resetPwdNewLabel => 'Neues Passwort';

  @override
  String get resetPwdMinLength => 'Mindestens 6 Zeichen';

  @override
  String get resetPwdConfirmLabel => 'Passwort bestätigen';

  @override
  String get resetPwdMismatch => 'Die Passwörter stimmen nicht überein';

  @override
  String get resetPwdSave => 'Passwort speichern';

  @override
  String get homeSearchHint => 'Promo oder Restaurant suchen...';

  @override
  String homeEmptySearch(Object query) {
    return 'Keine Ergebnisse für \"$query\"';
  }

  @override
  String get homeEmptyFilters => 'Keine Ergebnisse für diese Filter';

  @override
  String get homeEmptyNoPromos => 'Hier gibt es noch keine Angebote';

  @override
  String get homeClearSearchAndFilters => 'Suche und Filter zurücksetzen';

  @override
  String get homeRetry => 'Erneut versuchen';

  @override
  String get promoDetailNew => 'Neu';

  @override
  String get promoDetailBirthdayGift => 'Dein Geburtstagsgeschenk';

  @override
  String promoDetailConditions(Object terms) {
    return 'Bedingungen: $terms';
  }

  @override
  String get promoDetailDescription => 'Beschreibung';

  @override
  String get promoDetailAvailability => 'Verfügbarkeit';

  @override
  String get promoDetailShare => 'Teilen';

  @override
  String get promoDetailSaved => 'Gespeichert';

  @override
  String get promoDetailSave => 'Speichern';

  @override
  String get promoDetailFlash => '⚡ Blitz';

  @override
  String promoDetailFlashEndsInHours(Object hours, Object minutes) {
    return '⚡ Endet in ${hours}h ${minutes}m';
  }

  @override
  String promoDetailFlashEndsInMinutes(Object minutes) {
    return '⚡ Endet in ${minutes}m';
  }

  @override
  String get restaurantNew => 'Neu';

  @override
  String get restaurantTypeUrbanMobile => 'Urban / Mobil';

  @override
  String get restaurantTypeLocal => 'Ladengeschäft';

  @override
  String get restaurantCall => 'Anrufen';

  @override
  String get restaurantWebsite => 'Web';

  @override
  String get restaurantCharacteristics => 'Merkmale';

  @override
  String get restaurantPaymentMethods => 'Zahlungsmethoden';

  @override
  String get restaurantSchedule => 'Öffnungszeiten';

  @override
  String get restaurantClosed => 'Geschlossen';

  @override
  String get restaurantLocation => 'Standort';

  @override
  String get restaurantViewOnMap => 'Auf Karte ansehen';

  @override
  String get restaurantGetDirections => 'Route';

  @override
  String get restaurantPhotos => 'Fotos';

  @override
  String get restaurantLoyaltyProgram => 'Treueprogramm';

  @override
  String restaurantVisitsCount(Object count) {
    return '$count Besuche';
  }

  @override
  String restaurantValidUntil(Object date, Object days) {
    return 'Gültig bis $date · $days Tage';
  }

  @override
  String restaurantEnded(Object date) {
    return 'Endete $date';
  }

  @override
  String get restaurantViewStampsAndQr => 'Meine Stempel und QR ansehen';

  @override
  String get restaurantActivePromos => 'Aktive Angebote';

  @override
  String get restaurantNoActivePromos => 'Derzeit keine aktiven Angebote.';

  @override
  String get restaurantNoPromosToday => 'Keine Angebote für heute.';

  @override
  String get restaurantAlsoThisWeek => 'Auch diese Woche';

  @override
  String get restaurantFlash => 'Flash';

  @override
  String get restaurantRetry => 'Erneut versuchen';

  @override
  String get lugaresSearchHint => 'Geschäft suchen...';

  @override
  String get lugaresChipOpenNow => 'Jetzt geöffnet';

  @override
  String get lugaresChipFlash => '⚡ Blitz';

  @override
  String get lugaresChipFavorites => '⭐ Meine Favoriten';

  @override
  String get lugaresChipMoreFilters => 'Mehr Filter';

  @override
  String lugaresChipFiltersCount(Object count) {
    return 'Filter ($count)';
  }

  @override
  String get lugaresFiltersTitle => 'Filter';

  @override
  String get lugaresClearAll => 'Alle löschen';

  @override
  String get lugaresSectionCharacteristics => 'Merkmale des Ortes';

  @override
  String get lugaresSectionCategory => 'Kategorie';

  @override
  String get lugaresSectionDay => 'Tag';

  @override
  String get lugaresSectionPayment => 'Zahlungsmethode';

  @override
  String get lugaresDayMon => 'Mo';

  @override
  String get lugaresDayTue => 'Di';

  @override
  String get lugaresDayWed => 'Mi';

  @override
  String get lugaresDayThu => 'Do';

  @override
  String get lugaresDayFri => 'Fr';

  @override
  String get lugaresDaySat => 'Sa';

  @override
  String get lugaresDaySun => 'So';

  @override
  String get lugaresPaymentCash => 'Bargeld';

  @override
  String get lugaresPaymentCard => 'Karte';

  @override
  String get lugaresPaymentTransfer => 'Überweisung';

  @override
  String get lugaresPaymentMercadopago => 'MercadoPago';

  @override
  String lugaresApplyWithCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filter',
      one: 'Filter',
    );
    return 'Anwenden ($count $_temp0)';
  }

  @override
  String get lugaresApplyFilters => 'Filter anwenden';

  @override
  String get lugaresEmptyFiltered => 'Keine Ergebnisse für die angewendeten Filter';

  @override
  String get lugaresEmptyNoNearby => 'Im Moment keine Geschäfte in der Nähe';

  @override
  String get lugaresClearFilters => 'Filter löschen';

  @override
  String get lugaresRetry => 'Erneut versuchen';

  @override
  String get stampsTitle => 'Meine Stempel';

  @override
  String get stampsMyQrTooltip => 'Mein Besuchs-QR';

  @override
  String get stampsSectionReady => 'Belohnungen bereit zum Einlösen';

  @override
  String get stampsSectionInProgress => 'In Bearbeitung';

  @override
  String get stampsSuffixProgram => 'Programm';

  @override
  String get stampsSuffixPrograms => 'Programme';

  @override
  String get stampsSectionEarned => 'Verdiente Belohnungen';

  @override
  String get stampsSuffixTotal => 'insgesamt';

  @override
  String get stampsSeeAllRewards => 'Alle Belohnungen ansehen →';

  @override
  String get stampsTapForRedemptionQr => 'Tippen für Einlöse-QR';

  @override
  String get stampsReadyBadge => 'BEREIT!';

  @override
  String get stampsFinished => 'Beendet';

  @override
  String stampsVisitsCount(Object visits, Object required) {
    return '$visits/$required Besuche';
  }

  @override
  String stampsStampsLeft(Object count) {
    return 'Noch $count! 🔥';
  }

  @override
  String stampsExpiredOn(Object date) {
    return 'Abgelaufen am $date';
  }

  @override
  String stampsExpiresOn(Object date) {
    return 'Läuft ab am $date';
  }

  @override
  String get stampsRedeemed => 'Eingelöst';

  @override
  String get stampsRedeemReward => 'Belohnung einlösen';

  @override
  String stampsAtEstablishment(Object name) {
    return 'bei $name';
  }

  @override
  String stampsCodeLabel(Object code) {
    return 'Code: $code';
  }

  @override
  String get stampsShowCodeToStaff => 'Zeige diesen Code dem Personal';

  @override
  String get stampsStaffWillScan => 'Sie scannen ihn, um deine Belohnung zu bestätigen';

  @override
  String get stampsMyQrTitle => 'Mein QR-Code';

  @override
  String get stampsMyQrSubtitle => 'Zeige diesen Code dem Geschäft, um deinen Besuch zu registrieren.';

  @override
  String get stampsUniqueAccountCode => 'Dein eindeutiger Konto-Code';

  @override
  String get stampsRetry => 'Erneut versuchen';

  @override
  String get stampsEmptyTitle => 'Du hast noch keine Stempel';

  @override
  String get stampsEmptyMsg => 'Besuche Geschäfte mit einem Treueprogramm und zeige ihnen deinen QR-Code, um Stempel zu sammeln.';

  @override
  String get stampsViewMyQr => 'Meinen QR ansehen';

  @override
  String get loyaltyTitle => 'Treueprogramm';

  @override
  String get loyaltyScan => 'Scannen';

  @override
  String get loyaltyStatusDeactivated => 'Deaktiviert';

  @override
  String loyaltyStatusExpired(Object date) {
    return 'Abgelaufen am $date';
  }

  @override
  String loyaltyStatusExpiresIn(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Läuft in $days Tagen ab',
      one: 'Läuft in $days Tag ab',
    );
    return '$_temp0';
  }

  @override
  String loyaltyStatusActive(Object date) {
    return 'Aktiv — endet am $date';
  }

  @override
  String get loyaltyVisitsRequired => 'Erforderliche Besuche';

  @override
  String get loyaltyReward => 'Belohnung';

  @override
  String get loyaltyStart => 'Beginn';

  @override
  String get loyaltyEnd => 'Ende';

  @override
  String get loyaltyEndNow => 'Programm jetzt beenden';

  @override
  String get loyaltyCreateNew => 'Neues Programm erstellen';

  @override
  String get loyaltyEndDialogTitle => 'Programm beenden?';

  @override
  String get loyaltyEndDialogContent => 'Alle Kunden sammeln in diesem Programm keine Besuche mehr. Sie können jederzeit ein neues erstellen.';

  @override
  String get loyaltyCancel => 'Abbrechen';

  @override
  String get loyaltyEnd2 => 'Beenden';

  @override
  String get loyaltyNoProgramDesc => 'Binden Sie Ihre Kunden mit einem digitalen Stempelsystem. Legen Sie fest, wie viele Besuche nötig sind, um die Belohnung zu erhalten.';

  @override
  String get loyaltyCreate => 'Programm erstellen';

  @override
  String get loyaltyParticipants => 'Teilnehmer';

  @override
  String get loyaltyRewardWon => 'Belohnung erhalten';

  @override
  String get loyaltyViewClients => 'Kunden anzeigen';

  @override
  String get loyaltyClientsTitle => 'Meine Kunden';

  @override
  String get loyaltyClientsLoadError => 'Kunden konnten nicht geladen werden.';

  @override
  String get loyaltyClientsRetry => 'Erneut versuchen';

  @override
  String get loyaltyClientsCurrentProgram => 'AKTUELLES PROGRAMM';

  @override
  String loyaltyClientsParticipants(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teilnehmer',
      one: '$count Teilnehmer',
    );
    return '$_temp0';
  }

  @override
  String get loyaltyClientsEmptyProgram => 'Noch keine Kunden in diesem Programm. Scanne den QR-Code deiner ersten Besucher.';

  @override
  String get loyaltyClientsReward => 'Belohnung!';

  @override
  String loyaltyClientsStampsLeft(Object count) {
    return '$count bis zur Belohnung';
  }

  @override
  String get loyaltyClientsHistoryHeader => 'GÄSTEVERLAUF';

  @override
  String get loyaltyClientsHistorySubtitle => 'Gesamtzahl der per QR erfassten Besuche, absteigend sortiert.';

  @override
  String get loyaltyClientsEmptyHistory => 'Der Verlauf erscheint hier, sobald du deine Kunden per QR scannst.';

  @override
  String get loyaltyClientsColumnClient => 'Kunde';

  @override
  String get loyaltyClientsColumnVisits => 'Besuche';

  @override
  String get loyaltyClientsColumnSpent => 'Ausgaben';

  @override
  String get loyaltyClientsColumnLast => 'Letzte';

  @override
  String get qrInvalidCode => 'Ungültiger QR-Code. Bitte den Kunden, seinen Code zu zeigen.';

  @override
  String get qrScanTitle => 'Kunde scannen';

  @override
  String get qrTorch => 'Taschenlampe';

  @override
  String get qrPointInstruction => 'Auf den QR-Code des Kunden richten';

  @override
  String get qrErrorUnauthorized => 'Du hast keine Berechtigung, Besuche in diesem Programm zu erfassen.';

  @override
  String get qrErrorProgramInactive => 'Das Programm ist inaktiv oder abgelaufen.';

  @override
  String get qrErrorNetwork => 'Verbindungsfehler. Bitte versuche es erneut.';

  @override
  String get qrErrorUnexpected => 'Ein unerwarteter Fehler ist aufgetreten.';

  @override
  String get qrCouldNotRegister => 'Konnte nicht erfasst werden';

  @override
  String get qrRewardWonTitle => 'Belohnung gewonnen! 🎉';

  @override
  String qrRewardWonMessage(Object visits) {
    return 'Der Kunde hat $visits Besuche abgeschlossen. Zeit, ihm sein Geschenk zu überreichen!';
  }

  @override
  String get qrVisitRegistered => 'Besuch erfasst';

  @override
  String qrVisitsLeft(Object count) {
    return 'Dem Kunden fehlen noch $count Besuch(e) bis zur Belohnung.';
  }

  @override
  String get qrProgramCompleted => 'Das Programm wurde abgeschlossen!';

  @override
  String get qrBillAmountLabel => 'Rechnungsbetrag (optional)';

  @override
  String get qrBillAmountHint => 'z. B. 350';

  @override
  String get qrBillAmountHelper => 'Erfasse, wie viel der Kunde ausgegeben hat, um den ROI von Promofy zu messen.';

  @override
  String get qrDone => 'Fertig';

  @override
  String qrVisitsCount(Object current, Object total) {
    return '$current/$total Besuche';
  }

  @override
  String get loyaltyFormTitle => 'Neues Treueprogramm';

  @override
  String get loyaltyFormInfo => 'Der Kunde zeigt seinen QR-Code, den du bei jedem Besuch scannst. Sobald die erforderliche Anzahl an Besuchen erreicht ist, erhält er seine Belohnung. Wenn das Programm endet, kannst du ein neues erstellen und alle Zähler werden zurückgesetzt.';

  @override
  String get loyaltyFormVisitsLabel => 'Besuche bis zur Belohnung';

  @override
  String get loyaltyFormVisitsHint => 'z. B. 5';

  @override
  String get loyaltyFormVisitsSuffix => 'Besuche';

  @override
  String get loyaltyFormVisitsMin => 'Mindestens 2 Besuche';

  @override
  String get loyaltyFormVisitsMax => 'Höchstens 50 Besuche';

  @override
  String get loyaltyFormRewardLabel => 'Was bekommt der Kunde?';

  @override
  String get loyaltyFormRewardHint => 'z. B. Gratis-Kaffee, 20 % Rabatt, gratis Dessert…';

  @override
  String get loyaltyFormRewardRequired => 'Beschreibe die Belohnung';

  @override
  String get loyaltyFormValidityLabel => 'Gültigkeit des Programms';

  @override
  String get loyaltyFormStartLabel => 'Beginn';

  @override
  String get loyaltyFormEndLabel => 'Ende';

  @override
  String get loyaltyFormSelectDate => 'Auswählen';

  @override
  String get loyaltyFormSaving => 'Wird gespeichert…';

  @override
  String get loyaltyFormSubmit => 'Programm aktivieren';

  @override
  String get loyaltyFormSelectEndDate => 'Wähle das Enddatum des Programms aus.';

  @override
  String get loyaltyFormCreateError => 'Programm konnte nicht erstellt werden. Bitte versuche es erneut.';

  @override
  String get plansWebviewSubscriptionTitle => 'Promofy-Abonnement';

  @override
  String get plansWebviewAddonTitle => 'Add-on kaufen';

  @override
  String get plansAppBarTitle => 'Tarife & Zahlungen';

  @override
  String get plansRetry => 'Erneut versuchen';

  @override
  String get plansPaymentApprovedTitle => 'Zahlung genehmigt!';

  @override
  String get plansPaymentPendingTitle => 'Zahlung in Bearbeitung';

  @override
  String get plansPaymentApprovedBody => 'Dein Abonnement wurde erfolgreich aktiviert. Du kannst jetzt alle Vorteile deines Tarifs nutzen.';

  @override
  String get plansPaymentPendingBody => 'Deine Zahlung wird verarbeitet. Sobald sie bestätigt ist, wird dein Tarif automatisch aktualisiert.';

  @override
  String get plansGotIt => 'Verstanden';

  @override
  String get plansLaunchPromoTitle => 'Einführungsangebot';

  @override
  String get plansLaunchPromoSubtitle => 'Ab 99 MXN. Den Wert deines Tarifs erhältst du als Werbeguthaben zurück.';

  @override
  String get plansLaunchPromoValidUntil => 'Gültig bis 18. Juli 2026';

  @override
  String get plansActivePlanFallback => 'Aktiver Tarif';

  @override
  String get plansNoActivePlan => 'Kein aktiver Tarif';

  @override
  String get plansCurrentPlanLabel => 'Dein aktueller Tarif';

  @override
  String get plansActiveBadge => 'Aktiv';

  @override
  String get plansCurrentBadge => 'Aktuell';

  @override
  String plansPricePerMonth(Object amount) {
    return '$amount MXN/Monat';
  }

  @override
  String get plansFree => 'Kostenlos';

  @override
  String get plansMxnPerMonthSuffix => ' MXN/Monat';

  @override
  String plansAdCredit(Object amount) {
    return '+$amount an Werbung';
  }

  @override
  String plansFeatureEstablishments(Object count) {
    return '$count Standort(e)';
  }

  @override
  String plansFeaturePromotions(Object count) {
    return '$count aktive Standardaktionen';
  }

  @override
  String get plansFeatureFlashSingle => '1 Blitzaktion pro Monat';

  @override
  String get plansFeatureFlashMulti => '1 Blitzaktion/Monat pro Standort';

  @override
  String get plansFeatureBirthdaySingle => 'Geburtstagsaktion';

  @override
  String get plansFeatureBirthdayMulti => 'Geburtstagsaktion pro Standort';

  @override
  String get plansFeatureLoyaltySingle => 'Treueprogramm';

  @override
  String get plansFeatureLoyaltyMulti => 'Treueprogramm pro Standort';

  @override
  String get plansFeatureStats => 'Echtzeit-Statistiken';

  @override
  String plansFeaturePush(Object count) {
    return '$count Push-Benachrichtigungen/Monat';
  }

  @override
  String get plansActivePlanButton => 'Aktiver Tarif';

  @override
  String get plansProcessing => 'Wird verarbeitet...';

  @override
  String get plansSubscribe => 'Abonnieren';

  @override
  String get plansAddonsLabel => 'ADD-ONS';

  @override
  String get plansAddonsDescription => 'Erweitere deinen Tarif mit monatlichen Add-ons. Sie werden monatlich abgerechnet und du kannst jederzeit kündigen.';

  @override
  String get plansAddonEstablishmentTitle => '1 zusätzlicher Standort';

  @override
  String get plansAddonEstablishmentDesc => 'Ein zusätzlicher Standort in deinem Konto. Wird monatlich abgerechnet, bis du kündigst.';

  @override
  String get plansAddonEstablishmentPrice => '199 MXN/Monat';

  @override
  String get plansAddonPromotionTitle => '1 zusätzliche Aktion';

  @override
  String get plansAddonPromotionDesc => 'Eine zusätzliche Aktion an einem beliebigen Standort. Wird monatlich abgerechnet, bis du kündigst.';

  @override
  String get plansAddonPromotionPrice => '49 MXN/Monat';

  @override
  String get plansBuy => 'Kaufen';

  @override
  String get plansActiveAddonsTitle => 'Meine aktiven Add-ons';

  @override
  String get plansActiveAddonsSubtitle => 'Sie verlängern sich monatlich. Jederzeit kündbar.';

  @override
  String get plansAddonPromotionLabel => 'Zusätzliche Aktion';

  @override
  String get plansAddonEstablishmentLabel => 'Zusätzlicher Standort';

  @override
  String get plansCancel => 'Abbrechen';

  @override
  String get plansCancelAddonTitle => 'Add-on kündigen';

  @override
  String plansCancelAddonConfirm(Object label) {
    return '\"$label\" kündigen? Ab nächstem Monat wird es nicht mehr berechnet.';
  }

  @override
  String plansCancelAddonConfirmWithPromos(Object count, Object label) {
    return '$count Aktion(en) werden deaktiviert und \"$label\" wird gekündigt. Fortfahren?';
  }

  @override
  String get plansNo => 'Nein';

  @override
  String get plansYesCancel => 'Ja, kündigen';

  @override
  String get plansAddonCancelled => 'Add-on gekündigt.';

  @override
  String get plansCancelError => 'Kündigung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String plansDeactivateDialogTitle(Object count) {
    return '$count Aktion(en) deaktivieren';
  }

  @override
  String plansDeactivateDialogBody(Object count) {
    return 'Durch die Kündigung dieses Add-ons überschreitest du dein Limit. Wähle $count zum Deaktivieren:';
  }

  @override
  String get plansPromoFallback => 'Aktion';

  @override
  String get plansContinue => 'Weiter';

  @override
  String get paymentSecureTitle => 'Sichere Zahlung';

  @override
  String get paymentOpeningBrowser => 'MercadoPago wird in deinem Browser geöffnet...';

  @override
  String get paymentCancelTooltip => 'Zahlung abbrechen';

  @override
  String get profileTitle => 'Mein Profil';

  @override
  String get profileSignOut => 'Abmelden';

  @override
  String get profileNoName => 'Kein Name';

  @override
  String get profileBusinessOwnerChip => 'Geschäftsinhaber';

  @override
  String get profileLevelBusinessActive => 'Aktives Geschäft';

  @override
  String get profileLevelStaff => 'Mitarbeiter';

  @override
  String get profileAccountInfoTitle => 'Kontoinformationen';

  @override
  String get profileFieldName => 'Name';

  @override
  String get profileFieldBirthDate => 'Geburtsdatum';

  @override
  String get profileFieldGender => 'Geschlecht';

  @override
  String get profileGenderMale => 'Männlich';

  @override
  String get profileGenderFemale => 'Weiblich';

  @override
  String get profileGenderOther => 'Andere';

  @override
  String get profileBusinessMembershipTitle => 'Geschäftsmitgliedschaft';

  @override
  String get profileGoToMyBusiness => 'Zu Mein Geschäft';

  @override
  String get profileViewPlansAndPayments => 'Pläne und Zahlungen ansehen';

  @override
  String get profileBasicPlan => 'Basis-Plan';

  @override
  String get profileNoExpiry => 'Kein Ablaufdatum';

  @override
  String profileExpired(Object date) {
    return 'Abgelaufen ($date)';
  }

  @override
  String profileExpiresOn(Object date) {
    return 'Läuft am $date ab';
  }

  @override
  String get profileHaveBusinessTitle => 'Hast du ein Geschäft?';

  @override
  String get profileHaveBusinessSubtitle => 'Registriere es und erreiche mehr Kunden';

  @override
  String get profileRegisterIt => 'Registrieren';

  @override
  String get profileSheetTitleLoaded => 'Bereits auf Promofy';

  @override
  String get profileSheetTitleCode => 'Gib deinen Code ein';

  @override
  String get profileSheetTitleNoCode => 'Finde dein Geschäft';

  @override
  String get profileSheetTitleInitial => 'Registriere dein Geschäft';

  @override
  String get profileOptionNewTitle => 'Es ist neu';

  @override
  String get profileOptionNewSubtitle => 'Ich möchte mein Geschäft auf Promofy registrieren';

  @override
  String get profileOptionLoadedTitle => 'Es ist bereits eingetragen';

  @override
  String get profileOptionLoadedSubtitle => 'Mein Geschäft existiert bereits auf Promofy';

  @override
  String get profileOptionHaveCodeTitle => 'Ich habe einen Code';

  @override
  String get profileOptionHaveCodeSubtitle => 'Meinen Einladungscode eingeben';

  @override
  String get profileOptionNoCodeTitle => 'Ich habe keinen Code';

  @override
  String get profileOptionNoCodeSubtitle => 'Mein Geschäft nach Name und Adresse suchen';

  @override
  String get profileEnterInvitationCode => 'Gib deinen Einladungscode ein.';

  @override
  String get profileInvalidCode => 'Ungültiger Code.';

  @override
  String get profileConnectionError => 'Verbindungsfehler.';

  @override
  String get profileInvitationCodeHint => 'EINLADUNGSCODE';

  @override
  String get profileVerifyCode => 'Code überprüfen';

  @override
  String get profileValidCode => 'Gültiger Code!';

  @override
  String get profileEstablishmentFound => 'Geschäft gefunden';

  @override
  String get profileChooseMyPlan => 'Meinen Plan wählen';

  @override
  String get profileBusinessNameHint => 'Name deines Geschäfts';

  @override
  String get profileAddressHint => 'Adresse (Straße, Nummer, Viertel…)';

  @override
  String get profileEnterBusinessName => 'Gib den Namen deines Geschäfts ein.';

  @override
  String get profileSearchError => 'Fehler bei der Suche. Bitte erneut versuchen.';

  @override
  String get profileSearchMyBusiness => 'Mein Geschäft suchen';

  @override
  String get profileNoMatches => 'Keine Treffer gefunden.\nÜberprüfe den Namen oder die Adresse.';

  @override
  String get profileSelectYourBusiness => 'Wähle dein Geschäft:';

  @override
  String get profileYourBusiness => 'Dein Geschäft';

  @override
  String get profileAddressMatchQuestion => 'Wir haben bestätigt, dass die Adresse übereinstimmt. Ist das dein Geschäft?';

  @override
  String get profileYesItsMineChoosePlan => 'Ja, es ist meins — Plan wählen';

  @override
  String get profileNotThisBusiness => 'Nicht dieses Geschäft';

  @override
  String get profileBack => 'Zurück';

  @override
  String get profileFavoritesTitle => 'Meine Favoriten';

  @override
  String get profileFavoritesSubtitle => 'Gespeicherte Angebote und Geschäfte';

  @override
  String get profileSettingsTitle => 'Einstellungen';

  @override
  String get profileSettingsSubtitle => 'Name, Radius, Vorlieben, Passwort und Konto';

  @override
  String get profileWorkplacesTitle => 'Meine Arbeitsorte';

  @override
  String get profileNoWorkplaces => 'Keine zugeordneten Geschäfte gefunden.';

  @override
  String get profileRoleManager => 'Manager';

  @override
  String get profileRoleCashierWaiter => 'Kassierer / Kellner';

  @override
  String get profileRoleCashier => 'Kassierer';

  @override
  String get profileRoleCustom => 'Benutzerdefiniert';

  @override
  String profileRoleLabel(Object role) {
    return 'Rolle: $role';
  }

  @override
  String get profilePermLoyaltyQr => 'Treue-QR';

  @override
  String get profilePermStats => 'Statistiken';

  @override
  String get profilePermPromos => 'Angebote';

  @override
  String get profileWorkAtBusinessTitle => 'Arbeitest du in einem Geschäft?';

  @override
  String get profileWorkAtBusinessSubtitle => 'Gib deinen Einladungscode ein';

  @override
  String get profileJoin => 'Beitreten';

  @override
  String get profileLinkCopied => 'Link in die Zwischenablage kopiert!';

  @override
  String profileReferralShareText(Object url) {
    return 'Tritt Promofy bei und gewinne mehr Kunden für dein Geschäft!\nErstelle dein Konto mit meinem Link und wir gewinnen beide:\n$url';
  }

  @override
  String get profileReferralShareSubject => 'Tritt Promofy bei';

  @override
  String get profileReferralTitle => 'Empfehlungsprogramm';

  @override
  String get profileReferralDescription => 'Lade andere Geschäfte mit deinem Link ein. Wenn sie eine kostenpflichtige Mitgliedschaft aktivieren, erhältst du 300 MXN an Werbeguthaben.';

  @override
  String get profileCreditsEarned => 'Verdientes Guthaben';

  @override
  String get profileCopied => 'Kopiert';

  @override
  String get profileCopyLink => 'Link kopieren';

  @override
  String get profileShare => 'Teilen';

  @override
  String get profileReferralLinkSoon => 'Dein Empfehlungslink ist in Kürze verfügbar.';

  @override
  String get profileAchievementsTitle => 'Meine Erfolge';

  @override
  String get profileSeeAll => 'Alle ansehen';

  @override
  String profileVisitsToNextBadge(Object visits, Object toGo, Object nextBadge) {
    return '$visits Besuche · noch $toGo bis $nextBadge';
  }

  @override
  String profileVisitsMaxLevel(Object visits) {
    return '$visits Besuche dieses Jahr — Höchststufe!';
  }

  @override
  String profileStreakWeeks(Object weeks) {
    return '$weeks Wo. Serie';
  }

  @override
  String profileTopInCity(Object percent) {
    return 'Top $percent% in deiner Stadt';
  }

  @override
  String get profileWelcomeToTeam => 'Willkommen im Team!';

  @override
  String get profileJoinATeam => 'Einem Team beitreten';

  @override
  String get profileContinue => 'Weiter';

  @override
  String get profileCancel => 'Abbrechen';

  @override
  String get profileJoinMe => 'Beitreten';

  @override
  String get profileCodeSixChars => 'Der Code muss 6 Zeichen lang sein.';

  @override
  String get profileCodeInvalidOrExpired => 'Ungültiger oder abgelaufener Code.';

  @override
  String get profileConnectionErrorRetry => 'Verbindungsfehler. Bitte erneut versuchen.';

  @override
  String get profileEnterSixCharCode => 'Gib den 6-stelligen Code ein, den dir der Administrator gegeben hat.';

  @override
  String get profileWillUpdateOnContinue => 'Dein Profil wird beim Fortfahren aktualisiert.';

  @override
  String get settingsName => 'Name';

  @override
  String get settingsNameHint => 'Dein vollständiger Name';

  @override
  String get settingsNameEmpty => 'Der Name darf nicht leer sein.';

  @override
  String get settingsSearchRadius => 'Suchradius';

  @override
  String get settingsPreferredTypes => 'Bevorzugte Ortstypen';

  @override
  String get settingsFavoriteFood => 'Lieblingsessen';

  @override
  String get settingsLoadingCategories => 'Kategorien werden geladen…';

  @override
  String get settingsSaveButton => 'Einstellungen speichern';

  @override
  String get settingsSaved => 'Einstellungen gespeichert.';

  @override
  String get settingsSaveError => 'Fehler beim Speichern. Bitte versuche es erneut.';

  @override
  String get settingsAccountSecurity => 'Konto und Sicherheit';

  @override
  String get settingsChangePassword => 'Passwort ändern';

  @override
  String get settingsNewPassword => 'Neues Passwort';

  @override
  String get settingsConfirmPassword => 'Passwort bestätigen';

  @override
  String get settingsPasswordMin => 'Mindestens 6 Zeichen';

  @override
  String get settingsPasswordMismatch => 'Stimmen nicht überein';

  @override
  String get settingsPasswordUpdated => 'Passwort aktualisiert.';

  @override
  String get settingsPasswordError => 'Das Passwort konnte nicht geändert werden. Bitte versuche es erneut.';

  @override
  String get settingsCancel => 'Abbrechen';

  @override
  String get settingsSave => 'Speichern';

  @override
  String get settingsDeleteAccount => 'Konto löschen';

  @override
  String get settingsDeleteConfirmTitle => 'Bist du sicher?';

  @override
  String get settingsDeleteConfirmBody => 'Du verlierst all deine Daten: dein Profil, Favoriten, Treuestempel, Verlauf und, falls du ein Geschäft hast, die zugehörigen Daten.\n\nDiese Aktion ist endgültig und kann nicht rückgängig gemacht werden.';

  @override
  String settingsDeleteError(Object email) {
    return 'Das Konto konnte nicht gelöscht werden. Schreib uns an $email';
  }

  @override
  String get bizMyBusiness => 'Mein Geschäft';

  @override
  String get bizEditInfo => 'Informationen bearbeiten';

  @override
  String bizPromoLimitReached(Object max) {
    return 'Du hast dein Limit von $max Aktionen erreicht. Kaufe zusätzlichen Platz oder wechsle den Tarif, um mehr hinzuzufügen.';
  }

  @override
  String bizEstablishmentLimitReached(Object plan, Object max) {
    return 'Dein Tarif \"$plan\" erlaubt bis zu $max Standorte. Aktualisiere deinen Tarif, um mehr hinzuzufügen.';
  }

  @override
  String get bizStatsTitle => 'Statistiken deines Geschäfts';

  @override
  String get bizStatsGateDesc => 'Aktiviere einen Tarif, um Impressionen, Favoriten und die Demografie deines Publikums zu sehen.';

  @override
  String get bizViewPlans => 'Tarife ansehen';

  @override
  String get bizUsageBusinesses => 'Geschäfte';

  @override
  String get bizUsagePromos => 'Aktionen';

  @override
  String get bizUpgrade => 'Upgrade ↗';

  @override
  String get bizAdd => 'Hinzufügen';

  @override
  String get bizBusinessInfo => 'Geschäftsinformationen';

  @override
  String get bizNoExtraInfo => 'Keine zusätzlichen Informationen.';

  @override
  String get bizTypeLocal => 'Ladengeschäft';

  @override
  String get bizTypeUrbanMobile => 'Urban / Mobil';

  @override
  String get bizPaymentCard => 'Kredit-/Debitkarte';

  @override
  String get bizPaymentCash => 'Bargeld';

  @override
  String get bizPaymentOther => 'Sonstiges';

  @override
  String get bizAdultPromotions => 'Hat Aktionen für Erwachsene';

  @override
  String get bizDayMonday => 'Montag';

  @override
  String get bizDayTuesday => 'Dienstag';

  @override
  String get bizDayWednesday => 'Mittwoch';

  @override
  String get bizDayThursday => 'Donnerstag';

  @override
  String get bizDayFriday => 'Freitag';

  @override
  String get bizDaySaturday => 'Samstag';

  @override
  String get bizDaySunday => 'Sonntag';

  @override
  String get bizScheduleTitle => 'Öffnungszeiten';

  @override
  String get bizClosed => 'Geschlossen';

  @override
  String get bizMyPromos => 'Meine Aktionen';

  @override
  String get bizFeaturedHint => 'Aktiviere \"Hervorgehoben\", damit deine Aktion in der Suche zuerst erscheint.';

  @override
  String get bizNoPromosYet => 'Du hast noch keine Aktionen in diesem Geschäft.';

  @override
  String get bizPlanLimitTitle => 'Du hast das Limit deines Tarifs erreicht';

  @override
  String get bizBuyExtraSpaceDesc => 'Kaufe zusätzlichen Platz und veröffentliche weiter, ohne den Tarif zu wechseln.';

  @override
  String get bizBuyPromoSpace => 'Aktionsplatz kaufen';

  @override
  String bizEditAvailableOn(Object date) {
    return 'Bearbeitung verfügbar am $date';
  }

  @override
  String get bizPromoNotEditableYet => 'Diese Aktion kann noch nicht bearbeitet werden.';

  @override
  String bizEditableOn(Object date) {
    return 'Bearbeitbar am $date';
  }

  @override
  String get bizLocked => 'Gesperrt';

  @override
  String get bizFeatured => 'Hervorgehoben';

  @override
  String get bizFlash => 'Flash';

  @override
  String get bizMyTeam => 'Mein Team';

  @override
  String get bizInvite => 'Einladen';

  @override
  String get bizRemoveFromTeamTitle => 'Aus dem Team entfernen';

  @override
  String bizRemoveFromTeamConfirm(Object name) {
    return '$name aus dem Team entfernen?';
  }

  @override
  String get bizCancel => 'Abbrechen';

  @override
  String get bizRemove => 'Entfernen';

  @override
  String bizRemoveTeamError(Object error) {
    return 'Fehler beim Entfernen aus dem Team: $error';
  }

  @override
  String get bizNoStaffYet => 'Noch keine Mitarbeiter.\nTippe auf \"Einladen\", um einen Code zu erstellen.';

  @override
  String get bizRemoveFromTeamTooltip => 'Aus dem Team entfernen';

  @override
  String bizGenerateCodeError(Object error) {
    return 'Fehler beim Erstellen des Codes: $error';
  }

  @override
  String get bizInviteStaff => 'Mitarbeiter einladen';

  @override
  String get bizCodeAvailable48h => 'Der Code ist 48 Stunden lang gültig.';

  @override
  String get bizRoleLabel => 'ROLLE';

  @override
  String get bizRoleCashier => 'Kassierer / Kellner';

  @override
  String get bizRoleCashierDesc => 'Kann nur den Treue-QR-Code scannen';

  @override
  String get bizRoleManager => 'Manager';

  @override
  String get bizRoleManagerDesc => 'Statistiken, Aktionen und Treue-QR-Code';

  @override
  String get bizRoleCustom => 'Benutzerdefiniert';

  @override
  String get bizRoleCustomDesc => 'Berechtigungen manuell auswählen';

  @override
  String get bizPermissionsLabel => 'BERECHTIGUNGEN';

  @override
  String get bizPermScanQr => 'Treue-QR-Code scannen';

  @override
  String get bizPermViewStats => 'Statistiken ansehen';

  @override
  String get bizPermManagePromos => 'Aktionen verwalten';

  @override
  String get bizPermManagePayments => 'Zahlungen verwalten';

  @override
  String get bizGenerating => 'Wird erstellt…';

  @override
  String get bizGenerateCode => 'Code erstellen';

  @override
  String get bizCodeGenerated => 'Code erstellt';

  @override
  String bizCodeRole(Object role) {
    return 'Rolle: $role';
  }

  @override
  String get bizCodeValid48h => '48 Stunden gültig.\nTeile ihn mit dem Mitarbeiter zur Eingabe in der App.';

  @override
  String get bizCodeCopied => 'Code kopiert';

  @override
  String get bizCopyCode => 'Code kopieren';

  @override
  String get bizDone => 'Fertig';

  @override
  String get bizPushNotifications => 'Push-Benachrichtigungen';

  @override
  String get bizNoNotifications => 'Keine Benachrichtigungen in diesem Zeitraum.\nSie werden automatisch erstellt, wenn du eine Flash-Aktion anlegst.';

  @override
  String get bizKpiSent => 'Versendet';

  @override
  String get bizKpiReached => 'Erreicht';

  @override
  String get bizKpiOpenRate => 'Öffnungsrate';

  @override
  String get bizRecentHistory => 'NEUESTER VERLAUF';

  @override
  String bizNotifSentLine(Object date, Object count) {
    return '$date · $count versendet';
  }

  @override
  String bizOpenRateShort(Object pct) {
    return '$pct% Öffn.';
  }

  @override
  String get bizBoostBusiness => 'Bring dein Geschäft voran';

  @override
  String bizPlanIncludes(Object plan, Object establishments, Object promotions) {
    return 'Dein Tarif \"$plan\" umfasst bis zu $establishments Geschäfte und $promotions reguläre Aktionen.';
  }

  @override
  String get bizEmptyTagline => 'Veröffentliche Aktionen und erreiche Tausende Kunden in deiner Stadt.';

  @override
  String get bizRegisterMyBusiness => 'Mein Geschäft registrieren';

  @override
  String get bizAdvertising => 'Werbung';

  @override
  String get bizNewCampaign => 'Neue Kampagne';

  @override
  String get bizAvailableCredit => 'Verfügbares Guthaben';

  @override
  String bizReachableBanner(Object count) {
    return '≈ $count erreichbare Personen (Banner)';
  }

  @override
  String get bizTopUp => 'Aufladen';

  @override
  String get bizNoActiveCampaigns => 'Keine aktiven Kampagnen';

  @override
  String get bizOngoingCampaigns => 'Laufende Kampagnen';

  @override
  String bizSpent(Object amount) {
    return 'Ausgegeben: $amount';
  }

  @override
  String bizBudget(Object amount) {
    return 'Budget: $amount';
  }

  @override
  String get bizPause => 'Pausieren';

  @override
  String get bizResume => 'Fortsetzen';

  @override
  String get bizTransactionHistory => 'Bewegungsverlauf';

  @override
  String get bizRetry => 'Erneut versuchen';

  @override
  String get bizGeoBoth => 'Physisch + Suche';

  @override
  String get bizGeoPhysical => 'Nur physischer Standort';

  @override
  String get bizGeoSearchArea => 'Nur Suchbereich';

  @override
  String get bizErrorNameRequired => 'Der Name ist erforderlich';

  @override
  String get bizErrorBudgetInvalid => 'Gib ein gültiges Budget ein';

  @override
  String bizErrorMinBudget(Object amount) {
    return 'Mindestbudget für dieses Format: $amount';
  }

  @override
  String bizErrorInsufficientBalance(Object amount) {
    return 'Unzureichendes Guthaben. Verfügbar: $amount';
  }

  @override
  String get bizErrorSelectPromo => 'Wähle die Aktion aus, die du bewerben möchtest';

  @override
  String get bizCampaignName => 'Kampagnenname';

  @override
  String get bizWhatToAdvertise => 'Was möchtest du bewerben?';

  @override
  String get bizYourBusiness => 'Dein Geschäft';

  @override
  String get bizOnePromotion => 'Eine Aktion';

  @override
  String get bizWhereToShow => 'Wo möchtest du es anzeigen?';

  @override
  String get bizPlacementSplash => 'Splash beim Öffnen der App';

  @override
  String get bizPlacementFeed => 'Im Aktions-Feed';

  @override
  String get bizPlacementBanner => 'Banner auf der Startseite';

  @override
  String get bizSpecialFormats => 'Sonderformate';

  @override
  String get bizFormatPush => 'Push-Benachr.';

  @override
  String get bizFormatFlash => 'Blitz-Aktion';

  @override
  String get bizBudgetMxn => 'Budget (MXN)';

  @override
  String bizMinimum(Object amount) {
    return 'Mindestens $amount';
  }

  @override
  String bizEstimatedReach(Object count) {
    return 'Geschätzte Reichweite: $count Personen';
  }

  @override
  String get bizRadius => 'Radius:';

  @override
  String get bizGeoSegmentation => 'Geografische Ausrichtung';

  @override
  String get bizAge => 'Alter:';

  @override
  String bizAgeRange(Object min, Object max) {
    return '$min – $max Jahre';
  }

  @override
  String bizYearsOld(Object age) {
    return '$age Jahre';
  }

  @override
  String get bizGender => 'Geschlecht';

  @override
  String get bizGenderAll => 'Alle';

  @override
  String get bizGenderMale => 'Männer';

  @override
  String get bizGenderFemale => 'Frauen';

  @override
  String bizAudienceWithFilters(Object count) {
    return 'Publikum mit diesen Filtern: $count Personen';
  }

  @override
  String get bizCalculatingAudience => 'Publikum wird berechnet...';

  @override
  String get bizPromoToAdvertise => 'Zu bewerbende Aktion';

  @override
  String get bizCreatePromoFirst => 'Erstelle mindestens eine aktive Aktion, bevor du eine Kampagne startest.';

  @override
  String get bizLaunchCampaign => 'Kampagne starten';

  @override
  String get bizRefresh => 'Aktualisieren';

  @override
  String get bizNoAssignedEstablishments => 'Keine zugewiesenen Standorte';

  @override
  String get bizAskOwnerToInvite => 'Bitte den Geschäftsinhaber, dich mit einem Code einzuladen.';

  @override
  String get bizPermManagePromosShort => 'Aktionen verwalten';

  @override
  String get bizScanStamps => 'Stempel scannen';

  @override
  String get bizPromoTypeFlash => 'Flash';

  @override
  String get bizPromoTypeDaily => 'Täglich';

  @override
  String get bizPromoTypeWeekly => 'Wöchentlich';

  @override
  String get bizPromoTypePermanent => 'Dauerhaft';

  @override
  String get bizActive => 'Aktiv';

  @override
  String get bizInactive => 'Inaktiv';

  @override
  String get bizMinAmount50 => 'Gib einen Mindestbetrag von 50 MXN ein';

  @override
  String get bizCannotOpenMercadoPago => 'MercadoPago konnte nicht geöffnet werden';

  @override
  String get bizRedirectedToMercadoPago => 'Zu MercadoPago weitergeleitet. Dein Guthaben wird wenige Minuten nach der Zahlung aktualisiert.';

  @override
  String get bizTopUpAdCredit => 'Werbeguthaben aufladen';

  @override
  String get bizTopUpDesc => 'Jede Impression zieht Guthaben gemäß dem Kampagnenformat ab. Die Zahlung wird von MercadoPago abgewickelt.';

  @override
  String get bizAmountToTopUp => 'AUFZULADENDER BETRAG';

  @override
  String get bizOtherAmount => 'Anderer Betrag';

  @override
  String get bizMin50Mxn => 'Mindestens 50 MXN';

  @override
  String bizTotalToPay(Object amount) {
    return 'Zu zahlender Gesamtbetrag: $amount MXN';
  }

  @override
  String get bizPreparingPayment => 'Zahlung wird vorbereitet…';

  @override
  String get bizPayWithMercadoPago => 'Mit MercadoPago bezahlen';

  @override
  String get bizWillRedirectMercadoPago => 'Du wirst zur MercadoPago-Website weitergeleitet.';

  @override
  String get regBizCreateTitle => 'Unternehmen registrieren';

  @override
  String get regBizEditTitle => 'Unternehmen bearbeiten';

  @override
  String get regBizBack => 'Zurück';

  @override
  String get regBizNext => 'Weiter';

  @override
  String get regBizSaveChanges => 'Änderungen speichern';

  @override
  String regBizStepOf(Object step, Object total) {
    return 'Schritt $step von $total';
  }

  @override
  String get regBizStepBasic => 'Grunddaten';

  @override
  String get regBizStepType => 'Typ und Kategorie';

  @override
  String get regBizStepSchedule => 'Öffnungszeiten und Extras';

  @override
  String get regBizUpdatedOk => 'Unternehmen erfolgreich aktualisiert.';

  @override
  String get regBizCreatedOk => 'Unternehmen registriert! Du erscheinst jetzt auf Promofy.';

  @override
  String get regBizSelectAddressHint => 'Wähle eine Adresse aus der Suche, um den Standort zu erhalten.';

  @override
  String get regBizSelectType => 'Wähle die Art des Betriebs aus.';

  @override
  String get regBizSelectCategory => 'Wähle mindestens eine Kategorie aus.';

  @override
  String get regBizSelectCharacteristic => 'Wähle mindestens ein Merkmal aus.';

  @override
  String get regBizSelectPayment => 'Wähle mindestens eine Zahlungsmethode aus.';

  @override
  String get regBizSelectDay => 'Füge mindestens einen Öffnungstag hinzu.';

  @override
  String get regBizSectionMain => 'Hauptinformationen';

  @override
  String get regBizNameLabel => 'Name des Unternehmens *';

  @override
  String get regBizNameHint => 'z. B. Tacos El Gordo';

  @override
  String get regBizNameRequired => 'Der Name ist erforderlich';

  @override
  String get regBizDescLabel => 'Beschreibung';

  @override
  String get regBizDescHint => 'Beschreibe kurz dein Unternehmen…';

  @override
  String get regBizSectionLocation => 'Standort';

  @override
  String get regBizAddressLabel => 'Adresse';

  @override
  String get regBizAddressLabelRequired => 'Adresse *';

  @override
  String get regBizAddressHint => 'Tippe, um die Adresse zu suchen…';

  @override
  String get regBizAddressHelper => 'Wähle die Adresse aus den Vorschlägen, um Koordinaten zu erhalten.';

  @override
  String get regBizSectionContact => 'Kontakt';

  @override
  String get regBizPhoneLabel => 'Telefon / WhatsApp';

  @override
  String get regBizPhoneHint => 'z. B. 4491234567';

  @override
  String get regBizSectionSocial => 'Soziale Medien';

  @override
  String get regBizWebsiteLabel => 'Webseite';

  @override
  String get regBizTypeSection => 'Art des Betriebs *';

  @override
  String get regBizTypeLocal => 'Ladengeschäft';

  @override
  String get regBizTypeLocalSub => 'Feste Adresse';

  @override
  String get regBizTypeMobile => 'Mobil / Unterwegs';

  @override
  String get regBizTypeMobileSub => 'Wechselnder Standort';

  @override
  String get regBizCategorySection => 'Kategorie *';

  @override
  String get regBizCategoryHelper => 'Du kannst eine oder mehrere auswählen. Die Unterkategorie ist optional.';

  @override
  String get regBizSubcategoryLabel => '↳ Unterkategorie (optional)';

  @override
  String get regBizSpecialtyLabel => '↳ Spezialität (optional)';

  @override
  String get regBizExtraSection => 'Zusätzliche Informationen';

  @override
  String get regBizAdultPromos => 'Gibt es Aktionen für Erwachsene?';

  @override
  String get regBizScheduleSection => 'Öffnungszeiten *';

  @override
  String get regBizScheduleHelper => 'Aktiviere die Tage, an denen du geöffnet hast, und passe die Zeiten an.';

  @override
  String get regBizCharSection => 'Merkmale *';

  @override
  String get regBizCharHelper => 'Wähle die aus, die auf dein Unternehmen zutreffen.';

  @override
  String get regBizPaymentSection => 'Zahlungsmethoden *';

  @override
  String get regBizPaymentCard => 'Kredit-/Debitkarte';

  @override
  String get regBizPaymentCash => 'Bargeld';

  @override
  String get regBizPaymentOther => 'Sonstiges';

  @override
  String get regBizClosed => 'Geschlossen';

  @override
  String get regBizDayMonday => 'Montag';

  @override
  String get regBizDayTuesday => 'Dienstag';

  @override
  String get regBizDayWednesday => 'Mittwoch';

  @override
  String get regBizDayThursday => 'Donnerstag';

  @override
  String get regBizDayFriday => 'Freitag';

  @override
  String get regBizDaySaturday => 'Samstag';

  @override
  String get regBizDaySunday => 'Sonntag';

  @override
  String get regBizSearchAddressTitle => 'Adresse suchen';

  @override
  String get regBizSearchAddressHint => 'Gib die Adresse deines Unternehmens ein…';

  @override
  String get regBizNoResults => 'Keine Ergebnisse. Versuche eine andere Suche.';

  @override
  String get regBizSearchError => 'Fehler bei der Suche. Bitte versuche es erneut.';

  @override
  String get regBizLocationError => 'Standort konnte nicht ermittelt werden.';

  @override
  String get promoFormEditTitle => 'Aktion bearbeiten';

  @override
  String get promoFormNewTitle => 'Neue Aktion';

  @override
  String get promoFormDelete => 'Löschen';

  @override
  String get promoFormCancel => 'Abbrechen';

  @override
  String get promoFormClear => 'Zurücksetzen';

  @override
  String get promoFormSelectThis => 'Diese auswählen';

  @override
  String get promoFormCategorySheetTitle => 'Aktionskategorie';

  @override
  String get promoFormCategoryLevel1 => 'Kategorie';

  @override
  String get promoFormSubcategory => 'Unterkategorie';

  @override
  String get promoFormSpecialty => 'Spezialität';

  @override
  String get promoFormOptionalTag => 'optional';

  @override
  String get promoFormStartDate => 'Startdatum';

  @override
  String get promoFormEndDate => 'Enddatum';

  @override
  String get promoFormStartTime => 'Startzeit';

  @override
  String get promoFormEndTime => 'Endzeit';

  @override
  String get promoFormEndTimeSameDay => 'Endzeit (gleicher Tag)';

  @override
  String get promoFormErrorNameRequired => 'Der Name ist erforderlich.';

  @override
  String get promoFormErrorSelectDay => 'Wähle mindestens einen Tag aus.';

  @override
  String get promoFormErrorStartDateTime => 'Gib Startdatum und -uhrzeit an.';

  @override
  String get promoFormErrorEndTime => 'Gib die Endzeit an.';

  @override
  String get promoFormErrorEndAfterStart => 'Die Endzeit muss nach dem Start liegen.';

  @override
  String get promoFormErrorSameDay => 'Eine Flash-Aktion muss am selben Tag beginnen und enden.';

  @override
  String get promoFormConfirmTitle => 'Stimmt alles?';

  @override
  String promoFormConfirmName(Object name) {
    return '\"$name\"';
  }

  @override
  String get promoFormConfirmIntro => 'Nach dem Erstellen ';

  @override
  String get promoFormConfirmLockWarning => 'kannst du diese Aktion 15 Tage lang nicht bearbeiten.';

  @override
  String get promoFormConfirmReview => '\n\nÜberprüfe Name, Beschreibung, Zeiten und aktive Tage sorgfältig, bevor du fortfährst.';

  @override
  String get promoFormReviewMore => 'Weiter prüfen';

  @override
  String get promoFormConfirmCreate => 'Ja, Aktion erstellen';

  @override
  String promoFormSaveError(Object error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String get promoFormDeleteTitle => 'Aktion löschen';

  @override
  String get promoFormDeleteConfirm => 'Diese Aktion löschen? Dies kann nicht rückgängig gemacht werden.';

  @override
  String promoFormDeleteError(Object error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String get promoFormTypeLabel => 'Aktionstyp';

  @override
  String get promoFormTypeNormal => 'Normal';

  @override
  String get promoFormTypeFlash => 'Flash ⚡';

  @override
  String get promoFormTypeBirthday => 'Geburtstag 🎂';

  @override
  String get promoFormTypeNormalDesc => 'Wiederholt sich jede Woche an den gewählten Tagen und Zeiten.';

  @override
  String get promoFormTypeFlashDesc => 'Einmaliges Event, nur einen Tag gültig. Maximal 1 Flash pro Monat.';

  @override
  String get promoFormTypeBirthdayDesc => 'Das ganze Jahr über für Kunden verfügbar, die Geburtstag haben.';

  @override
  String get promoFormNameLabel => 'Name *';

  @override
  String get promoFormNameHint => 'z. B.: 2 für 1 auf Cocktails';

  @override
  String get promoFormDescriptionLabel => 'Beschreibung';

  @override
  String get promoFormDescriptionHint => 'Erzähle deinen Kunden die Details';

  @override
  String get promoFormBirthdayGiftLabel => 'Geburtstagsgeschenk *';

  @override
  String get promoFormBirthdayGiftHint => 'z. B.: Gratis-Dessert, Getränk aufs Haus…';

  @override
  String get promoFormBirthdayTermsLabel => 'Bedingungen (optional)';

  @override
  String get promoFormBirthdayTermsHint => 'z. B.: Ausweis am Geburtstag vorzeigen';

  @override
  String get promoFormPhotoLabel => 'Foto (optional)';

  @override
  String get promoFormPhotoTapToAdd => 'Tippen, um ein Foto hinzuzufügen';

  @override
  String get promoFormCategoryLabel => 'Kategorie (optional)';

  @override
  String get promoFormCategorySelected => 'Ausgewählte Kategorie';

  @override
  String get promoFormCategoryLoading => 'Kategorien werden geladen...';

  @override
  String get promoFormCategoryNone => 'Keine Kategorie';

  @override
  String get promoFormAdultTitle => 'Inhalte für Erwachsene';

  @override
  String get promoFormAdultSubtitle => 'Nur für Nutzer ab 18 sichtbar';

  @override
  String get promoFormSaveChanges => 'Änderungen speichern';

  @override
  String get promoFormCreate => 'Aktion erstellen';

  @override
  String get promoFormActiveDaysLabel => 'Aktive Tage *';

  @override
  String get promoFormScheduleLabel => 'Zeitplan';

  @override
  String get promoFormStartLabel => 'Beginn';

  @override
  String get promoFormEndLabel => 'Ende';

  @override
  String get promoFormEventStartLabel => 'Eventbeginn *';

  @override
  String get promoFormEventEndLabel => 'Eventende *';

  @override
  String get promoFormEndTimeSameDayLabel => 'Endzeit * (gleicher Tag)';

  @override
  String get promoFormPickDateTime => 'Datum und Uhrzeit wählen';

  @override
  String get promoFormPickEndTime => 'Endzeit wählen';

  @override
  String get promoFormFlashInfo => 'Eine Flash-Aktion muss am selben Tag beginnen und enden. Pro Geschäft ist nur eine pro Monat erlaubt.';

  @override
  String get adminPlacesTitle => 'Orte verwalten';

  @override
  String get adminPlacesRefresh => 'Aktualisieren';

  @override
  String get adminPlacesTabEstablishments => 'Betriebe';

  @override
  String get adminPlacesTabPromos => 'Aktionen';

  @override
  String get adminPlacesAddPlace => 'Ort hinzufügen';

  @override
  String get adminPlacesSearchHint => 'Suchen…';

  @override
  String adminPlacesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Orte',
      one: '1 Ort',
    );
    return '$_temp0';
  }

  @override
  String get adminPlacesEmpty => 'Noch keine Orte. Tippe auf +, um einen hinzuzufügen.';

  @override
  String get adminPlacesNoResults => 'Keine Ergebnisse.';

  @override
  String get adminPlacesEditInfo => 'Infos bearbeiten';

  @override
  String get adminPlacesManagePhotos => 'Fotos verwalten';

  @override
  String get adminPlacesDelete => 'Löschen';

  @override
  String get adminPlacesManagePromos => 'Aktionen verwalten';

  @override
  String adminPlacesPhotosTitle(Object name) {
    return 'Fotos — $name';
  }

  @override
  String get adminPlacesDeleteTitle => 'Ort löschen';

  @override
  String adminPlacesDeleteConfirm(Object name) {
    return '\"$name\" löschen?\nDie zugehörigen Aktionen werden ebenfalls gelöscht.';
  }

  @override
  String get adminPlacesCancel => 'Abbrechen';

  @override
  String adminPlacesError(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get adminPlacesNoPlacesYet => 'Erstelle zuerst einen Ort im Tab Betriebe.';

  @override
  String get adminPlacesSelectPlace => 'Ort auswählen';

  @override
  String get adminPlacesNewPromo => 'Neue Aktion';

  @override
  String get adminPlacesChoosePlace => 'Wähle einen Ort, um seine Aktionen zu sehen.';

  @override
  String get adminPlacesNoPromos => 'Keine Aktionen. Tippe auf \"Neue Aktion\".';

  @override
  String get adminPlacesPromoActive => 'Aktiv';

  @override
  String get adminPlacesPromoInactive => 'Inaktiv';

  @override
  String get adminPlacesEdit => 'Bearbeiten';

  @override
  String get adminMetricsTitle => 'Admin-Bereich';

  @override
  String get adminMetricsManageRestaurants => 'Restaurants verwalten';

  @override
  String get adminMetricsRefresh => 'Kennzahlen aktualisieren';

  @override
  String get adminMetricsRetry => 'Erneut versuchen';

  @override
  String get adminMetricsAdminPlaces => 'Orte verwalten';

  @override
  String get adminMetricsAdminPlacesSubtitle => 'Admin-Einrichtungen und Aktionen verwalten';

  @override
  String get adminMetricsSectionUsers => 'Nutzer';

  @override
  String get adminMetricsNewUsers => 'Neue Nutzer';

  @override
  String get adminMetricsActiveUsers => 'Aktive Nutzer';

  @override
  String get adminMetricsPeriodToday => 'Heute';

  @override
  String get adminMetricsPeriod7d => '7 Tage';

  @override
  String get adminMetricsPeriod15d => '15 Tage';

  @override
  String get adminMetricsPeriod30d => '30 Tage';

  @override
  String get adminMetricsPeriodTotal => 'Gesamt';

  @override
  String get adminMetricsSectionPlatform => 'Plattform';

  @override
  String get adminMetricsEstablishments => 'Einrichtungen';

  @override
  String adminMetricsNewThisMonth(Object count) {
    return '$count diesen Monat';
  }

  @override
  String get adminMetricsActivePromos => 'Aktive Aktionen';

  @override
  String adminMetricsTotalCount(Object count) {
    return '$count gesamt';
  }

  @override
  String get adminMetricsSectionLoyaltyQr => 'Treue & QR';

  @override
  String get adminMetricsTotalScans => 'Scans gesamt';

  @override
  String adminMetricsLast30dValue(Object count) {
    return '$count letzte 30 Tage';
  }

  @override
  String get adminMetricsAvgTicket => 'Durchschnittsbon';

  @override
  String get adminMetricsWaiterUploadedAmount => 'Von Kellnern erfasster Betrag';

  @override
  String get adminMetricsSectionCampaigns => 'Werbekampagnen';

  @override
  String get adminMetricsActiveCampaigns => 'Aktive Kampagnen';

  @override
  String get adminMetricsCreditsSold => 'Verkaufte Credits';

  @override
  String get adminMetricsLast30days => 'letzte 30 Tage';

  @override
  String get adminMetricsCampaignSpend => 'Kampagnenausgaben';

  @override
  String get adminMetricsSectionSubscriptions => 'Abonnements';

  @override
  String get adminMetricsActiveSubscriptions => 'Aktive Abonnements';

  @override
  String get adminMetricsMonthlyIncome => 'monatliche Einnahmen';

  @override
  String get adminMetricsSectionPerformance => 'Leistung';

  @override
  String get adminMetricsRegisteredUsers => 'registrierte Nutzer';

  @override
  String get adminMetricsRoleUsers => 'Nutzer';

  @override
  String get adminMetricsRoleStaff => 'Personal';

  @override
  String get adminMetricsRoleBusiness => 'Unternehmen';

  @override
  String get adminMetricsRoleAdmin => 'Admin';

  @override
  String get adminMetricsPlatformRevenue30d => 'Plattformumsatz (30 Tage)';

  @override
  String get adminMetricsRevenueSubscriptions => 'Abonnements\n(MRR)';

  @override
  String get adminMetricsRevenueAdCredits => 'Werbe-Credits\n(30 Tage)';

  @override
  String get adminMetricsRevenueRoas => 'ROAS\n(Umsatz/Werbeausgaben)';

  @override
  String get adminMetricsNotAvailable => 'N/V';

  @override
  String get adminEstTitle => 'Admin-Restaurants';

  @override
  String get adminEstRefresh => 'Aktualisieren';

  @override
  String get adminEstAdd => 'Restaurant hinzufügen';

  @override
  String get adminEstSearchHint => 'Nach Name oder Adresse suchen…';

  @override
  String get adminEstLoading => 'Wird geladen…';

  @override
  String adminEstCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Betriebe',
      one: '1 Betrieb',
    );
    return '$_temp0';
  }

  @override
  String get adminEstRetry => 'Erneut versuchen';

  @override
  String get adminEstEmpty => 'Noch keine vom Admin verwalteten Restaurants.';

  @override
  String adminEstNoResults(Object query) {
    return 'Keine Ergebnisse für \"$query\".';
  }

  @override
  String get adminEstAddFirst => 'Erstes hinzufügen';

  @override
  String get adminEstDeleteTitle => 'Restaurant löschen';

  @override
  String adminEstDeleteConfirm(Object name) {
    return '\"$name\" löschen?\nDies löscht auch die zugehörigen Aktionen und Daten.';
  }

  @override
  String get adminEstCancel => 'Abbrechen';

  @override
  String get adminEstDelete => 'Löschen';

  @override
  String adminEstDeleted(Object name) {
    return '\"$name\" gelöscht.';
  }

  @override
  String adminEstDeleteError(Object error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String get adminEstEdit => 'Bearbeiten';

  @override
  String get statsTitle => 'Statistiken';

  @override
  String get statsRetry => 'Erneut versuchen';

  @override
  String get statsBusinessViews => 'Geschäftsaufrufe';

  @override
  String get statsPromoViews => 'Aktionsaufrufe';

  @override
  String get statsNewFavs => 'Neue Favoriten';

  @override
  String get statsContacts => 'Kontakte';

  @override
  String get statsQrVisits => 'QR-Besuche';

  @override
  String get statsTotalFavs => 'Favoriten gesamt';

  @override
  String get statsAvgTicket => 'Ø Bon';

  @override
  String get statsRevenue => 'Erzielter Umsatz';

  @override
  String get statsPromoBreakdown => 'AUFSCHLÜSSELUNG NACH AKTION';

  @override
  String get statsColPromo => 'Aktion';

  @override
  String get statsColViews => 'Aufrufe';

  @override
  String get statsColViewsTooltip => 'Wie oft das Detail geöffnet wurde';

  @override
  String get statsColNewFavs => 'Favoriten +';

  @override
  String get statsColNewFavsTooltip => 'Neue Favoriten im Zeitraum';

  @override
  String get statsColTotalFavs => 'Favoriten Σ';

  @override
  String get statsColTotalFavsTooltip => 'Gesamtzahl gesammelter Favoriten';

  @override
  String get statsContactChannels => 'KONTAKTKANÄLE';

  @override
  String get statsChannelPhone => 'Anruf';

  @override
  String get statsChannelWebsite => 'Webseite';

  @override
  String get statsChannelMaps => 'Karte';

  @override
  String statsAudienceHeader(Object total) {
    return 'PUBLIKUM ($total Favorisierende)';
  }

  @override
  String get statsGender => 'Geschlecht';

  @override
  String get statsAge => 'Alter';

  @override
  String get statsByPromo => 'Nach Aktion';

  @override
  String get statsGenderMale => 'Männer';

  @override
  String get statsGenderFemale => 'Frauen';

  @override
  String get statsGenderUnknown => 'K.A.';

  @override
  String get photosSectionTitle => 'Logo und Fotos';

  @override
  String get photosLogoTitle => 'Firmenlogo';

  @override
  String get photosLogoHint => 'Quadratisches Bild, mindestens 400×400 px.';

  @override
  String get photosChangeLogo => 'Logo ändern';

  @override
  String get photosUploadLogo => 'Logo hochladen';

  @override
  String get photosCategoryEstablishment => 'Fotos des Lokals';

  @override
  String get photosCategoryChildrenArea => 'Kinderbereich';

  @override
  String get photosCategoryMenu => 'Speisekarte';

  @override
  String get photosEmpty => 'Keine Fotos';

  @override
  String get photosDeleteTitle => 'Foto löschen';

  @override
  String get photosDeleteConfirm => 'Möchten Sie dieses Foto wirklich löschen?';

  @override
  String get photosCancel => 'Abbrechen';

  @override
  String get photosDelete => 'Löschen';

  @override
  String get photosErrorUploadLogo => 'Das Logo konnte nicht hochgeladen werden. Bitte versuchen Sie es erneut.';

  @override
  String get photosErrorUploadPhoto => 'Das Foto konnte nicht hochgeladen werden. Bitte versuchen Sie es erneut.';

  @override
  String get photosErrorDeletePhoto => 'Das Foto konnte nicht gelöscht werden. Bitte versuchen Sie es erneut.';

  @override
  String get adminPanelTitle => 'Superadmin-Panel';

  @override
  String get adminReload => 'Neu laden';

  @override
  String get adminLoadError => 'Fehler beim Laden';

  @override
  String get adminRetry => 'Erneut versuchen';

  @override
  String get adminSectionTitle => 'Verwaltung';

  @override
  String get adminTilePlans => 'Mitgliedschaftspläne';

  @override
  String adminTilePlansSubtitle(Object count) {
    return '$count Pläne konfiguriert';
  }

  @override
  String get adminTileOwners => 'Geschäftsinhaber';

  @override
  String adminTileOwnersSubtitle(Object count) {
    return '$count registrierte Inhaber';
  }

  @override
  String get adminTileCategories => 'Kategorien';

  @override
  String adminTileCategoriesSubtitle(Object count) {
    return '$count Kategorien · Typenbaum';
  }

  @override
  String get adminTileCharacteristics => 'Merkmale';

  @override
  String adminTileCharacteristicsSubtitle(Object count) {
    return '$count Merkmale';
  }

  @override
  String get adminTileNotifications => 'Push-Benachrichtigungen';

  @override
  String adminTileNotificationsSubtitle(Object devices, Object sends) {
    return '$devices Geräte · $sends protokollierte Sendungen';
  }

  @override
  String get adminTileAllUsers => 'Alle Benutzer';

  @override
  String get adminTileAllUsersSubtitle => 'Konten verwalten · aktivieren / deaktivieren';

  @override
  String get adminTileAds => 'Werbung';

  @override
  String get adminTileAdsSubtitle => 'Preise nach Format · Kampagnenverwaltung';

  @override
  String get adminTileCredits => 'Werbeguthaben';

  @override
  String get adminTileCreditsSubtitle => 'Guthaben zu Betriebskonten zuweisen';

  @override
  String get adminTileBulk => 'Massen-Upload von Aktionen';

  @override
  String get adminTileBulkSubtitle => 'Aktionen für Unternehmen erstellen · zählt nicht zum Plan';

  @override
  String get adminRoleFilterAll => 'Alle';

  @override
  String get adminRoleFilterUsers => 'Benutzer';

  @override
  String get adminRoleFilterStaff => 'Personal';

  @override
  String get adminRoleFilterOwners => 'Inhaber';

  @override
  String get adminRoleFilterAdmin => 'Admin';

  @override
  String adminErrorWithMsg(Object msg) {
    return 'Fehler: $msg';
  }

  @override
  String get adminAllUsersTitle => 'Alle Benutzer';

  @override
  String get adminSearchNameEmail => 'Nach Name oder E-Mail suchen…';

  @override
  String adminUserCount(Object count) {
    return '$count Benutzer';
  }

  @override
  String get adminNoResults => 'Keine Ergebnisse';

  @override
  String get adminAccountDeactivated => 'Konto deaktiviert';

  @override
  String get adminActivate => 'Aktivieren';

  @override
  String get adminDeactivate => 'Deaktivieren';

  @override
  String get adminActivateAccount => 'Konto aktivieren';

  @override
  String get adminDeactivateAccount => 'Konto deaktivieren';

  @override
  String adminActivateAccountConfirm(Object name) {
    return 'Konto von $name reaktivieren? Sie können sich wieder anmelden.';
  }

  @override
  String adminDeactivateAccountConfirm(Object name) {
    return 'Konto von $name deaktivieren? Sie können sich nicht anmelden und ihre Inhalte werden ausgeblendet.';
  }

  @override
  String get adminCancel => 'Abbrechen';

  @override
  String get adminPlansTitle => 'Mitgliedschaftspläne';

  @override
  String get adminAddons => 'Add-ons';

  @override
  String get adminAddonsDesc => 'Preise pro Einheit/Monat, die über dem Planlimit berechnet werden.';

  @override
  String get adminAddonTableMissing => 'Tabelle addon_pricing nicht gefunden.';

  @override
  String get adminAddonRunSql => 'Führe zuerst das Add-ons-SQL in Supabase aus.';

  @override
  String get adminOwnersTitle => 'Geschäftsinhaber';

  @override
  String adminResultCount(Object count) {
    return '$count Ergebnis(se)';
  }

  @override
  String get adminCategoriesTitle => 'Kategorien';

  @override
  String get adminNewRootType => 'Neuer Wurzeltyp';

  @override
  String get adminNoCategories => 'Keine Kategorien';

  @override
  String get adminLevelType => 'Typ';

  @override
  String get adminLevelSubtype => 'Untertyp';

  @override
  String get adminLevelSubSubtype => 'Unter-Untertyp';

  @override
  String get adminAddSubcategory => 'Unterkategorie hinzufügen';

  @override
  String get adminDeleteCategory => 'Kategorie löschen';

  @override
  String adminDeleteCategoryWithChildren(Object name, Object count) {
    return '\"$name\" löschen? Die $count Unterkategorie(n) werden ebenfalls gelöscht.';
  }

  @override
  String adminDeleteCategorySimple(Object name) {
    return '\"$name\" löschen?';
  }

  @override
  String get adminDelete => 'Löschen';

  @override
  String get adminCharacteristicsTitle => 'Merkmale';

  @override
  String get adminNewCharacteristic => 'Neues Merkmal';

  @override
  String get adminNoCharacteristics => 'Keine Merkmale';

  @override
  String get adminDeleteCharacteristic => 'Merkmal löschen';

  @override
  String adminDeleteCharacteristicConfirm(Object name) {
    return '\"$name\" löschen? Es wird aus allen Betrieben entfernt.';
  }

  @override
  String get adminFree => 'Kostenlos';

  @override
  String adminPricePerMonth(Object price) {
    return '$price MXN/Monat';
  }

  @override
  String adminBusinessCount(Object count) {
    return '$count Geschäft(e)';
  }

  @override
  String adminPromoCount(Object count) {
    return '$count Aktion(en)';
  }

  @override
  String get adminEditPlan => 'Plan bearbeiten';

  @override
  String get adminFreeNoCharge => 'Kostenlos / keine Gebühr';

  @override
  String get adminEditPrice => 'Preis bearbeiten';

  @override
  String adminEditLabel(Object label) {
    return 'Bearbeiten: $label';
  }

  @override
  String get adminInvalidPriceMin => 'Gib einen gültigen Preis ein (0 oder höher).';

  @override
  String get adminMonthlyPricePerUnit => 'Monatlicher Preis pro Einheit (MXN)';

  @override
  String get adminNoAdditionalCharge => '0 = keine zusätzliche Gebühr';

  @override
  String get adminAddonZeroHint => 'Gib 0 ein, wenn das Add-on kostenlos oder noch nicht aktiv ist.';

  @override
  String get adminSavePrice => 'Preis speichern';

  @override
  String adminEditPlanLabel(Object name) {
    return 'Plan bearbeiten: $name';
  }

  @override
  String get adminPriceMxnMonth => 'Preis (MXN/Monat)';

  @override
  String get adminZeroForFree => '0 für einen kostenlosen Plan';

  @override
  String get adminMaxEstablishments => 'Max. Betriebe';

  @override
  String get adminMaxActivePromos => 'Max. aktive Aktionen';

  @override
  String get adminSaveChanges => 'Änderungen speichern';

  @override
  String adminPlanPickerSubtitle(Object price, Object est, Object promos) {
    return '$price MXN/Monat · $est Gesch. · $promos Aktionen';
  }

  @override
  String get adminEdit => 'Bearbeiten';

  @override
  String get adminNameEmpty => 'Der Name darf nicht leer sein.';

  @override
  String get adminNewCategory => 'Neue Kategorie';

  @override
  String get adminEditCategory => 'Kategorie bearbeiten';

  @override
  String get adminNameRequired => 'Name *';

  @override
  String get adminEmojiIcon => 'Emoji / Symbol';

  @override
  String get adminBelongsToParent => 'Gehört zu (übergeordnet)';

  @override
  String get adminNoParentRoot => '— Kein übergeordnetes (Wurzeltyp) —';

  @override
  String get adminCreateCategory => 'Kategorie erstellen';

  @override
  String get adminEditCharacteristic => 'Merkmal bearbeiten';

  @override
  String get adminCreateCharacteristic => 'Merkmal erstellen';

  @override
  String get adminNotificationsTitle => 'Push-Benachrichtigungen';

  @override
  String get adminTabSend => 'Senden';

  @override
  String get adminTabScheduled => 'Geplant';

  @override
  String get adminTabHistory => 'Verlauf';

  @override
  String get adminTabMetrics => 'Metriken';

  @override
  String get adminCompleteTitleBody => 'Titel und Nachricht ausfüllen';

  @override
  String get adminCompleteTitleBodyBeforeSchedule => 'Titel und Nachricht vor dem Planen ausfüllen';

  @override
  String adminSentResult(Object count) {
    return '✅ An $count Geräte gesendet';
  }

  @override
  String adminSentResultWithFailed(Object count, Object failed) {
    return '✅ An $count Geräte gesendet · $failed fehlgeschlagen';
  }

  @override
  String adminSendErrorResult(Object msg) {
    return '❌ Fehler: $msg';
  }

  @override
  String get adminScheduledOk => '📅 Benachrichtigung erfolgreich geplant';

  @override
  String adminTotalDevices(Object count) {
    return 'Gesamt: $count Geräte';
  }

  @override
  String get adminTitleRequired => 'Titel *';

  @override
  String get adminTitleHint => 'Z. B. Neue Funktion verfügbar';

  @override
  String get adminMessageRequired => 'Nachricht *';

  @override
  String get adminBodyHint => 'Text schreiben…';

  @override
  String get adminSegmentRecipients => 'Empfänger segmentieren';

  @override
  String get adminGender => 'Geschlecht';

  @override
  String get adminAllGenders => 'Alle Geschlechter';

  @override
  String get adminAll => 'Alle';

  @override
  String get adminMen => 'Männer';

  @override
  String get adminWomen => 'Frauen';

  @override
  String get adminPreferNotToSay => 'Keine Angabe';

  @override
  String get adminAgeRange => 'Altersbereich';

  @override
  String get adminMin => 'Min';

  @override
  String get adminMax => 'Max';

  @override
  String get adminInactiveUsersSince => 'Inaktive Benutzer seit';

  @override
  String get adminNoFilter => 'Kein Filter';

  @override
  String get adminDays7 => '7 Tage';

  @override
  String get adminDays15 => '15 Tage';

  @override
  String get adminDays30 => '30 Tage';

  @override
  String get adminDays60 => '60 Tage';

  @override
  String get adminDays90Plus => '90 Tage oder mehr';

  @override
  String get adminPlatform => 'Plattform';

  @override
  String get adminAllFem => 'Alle';

  @override
  String get adminCalculating => 'Wird berechnet…';

  @override
  String adminRecipientsApprox(Object count) {
    return '~$count Empfänger';
  }

  @override
  String get adminEstimateRecipients => 'Empfänger schätzen';

  @override
  String get adminSchedule => 'Planen';

  @override
  String get adminSending => 'Wird gesendet…';

  @override
  String get adminSendNow => 'Jetzt senden';

  @override
  String get adminNoScheduled => 'Keine geplanten Benachrichtigungen';

  @override
  String get adminNoScheduledHint => 'Verwende den Tab Senden → Planen';

  @override
  String adminNextSend(Object date) {
    return 'Nächste: $date';
  }

  @override
  String adminRunCount(Object count) {
    return '$count Ausführung(en)';
  }

  @override
  String get adminNoSends => 'Keine Sendungen protokolliert.';

  @override
  String get adminTotalSent => 'Insgesamt gesendet';

  @override
  String get adminAvgDelivery => 'Durchschn. Zustellung';

  @override
  String get adminAvgOpen => 'Durchschn. Öffnung';

  @override
  String get adminDailySends30 => 'Tägliche Sendungen — letzte 30 Tage';

  @override
  String get adminLegendSent => 'Gesendet';

  @override
  String get adminLegendOpens => 'Öffnungen';

  @override
  String get adminNoSendData => 'Noch keine Sendedaten.';

  @override
  String get adminDevicesByPlatform => 'Geräte nach Plattform';

  @override
  String get adminLatestNotifications => 'Neueste Benachrichtigungen';

  @override
  String get adminColNotification => 'Benachrichtigung';

  @override
  String get adminColDelivery => 'Zustellung';

  @override
  String get adminColOpen => 'Öffnung';

  @override
  String get adminPickDateTime => 'Wähle Sendedatum und -uhrzeit';

  @override
  String get adminScheduleNotification => 'Benachrichtigung planen';

  @override
  String get adminSendDateTime => 'Sendedatum und -uhrzeit *';

  @override
  String get adminSelect => 'Auswählen…';

  @override
  String get adminRepetition => 'Wiederholung';

  @override
  String get adminOnceOnly => 'Nur einmal';

  @override
  String get adminDaily => 'Täglich';

  @override
  String get adminWeekly => 'Wöchentlich';

  @override
  String get adminMonthly => 'Monatlich';

  @override
  String get adminDelivered => 'zugestellt';

  @override
  String get adminFailed => 'fehlgeschlagen';

  @override
  String get adminOpenStat => 'Öffnung';

  @override
  String get adminDeliveryStat => 'Zustellung';

  @override
  String get adminAdsPricesTitle => 'Werbung · Preise';

  @override
  String get adminNoPriceData => 'Keine Preisdaten';

  @override
  String get adminRunAdsSql => 'Führe zuerst das Werbe-SQL in Supabase aus.';

  @override
  String get adminPricesByFormat => 'Preise nach Format';

  @override
  String adminUsersCount(Object count) {
    return '$count Benutzer';
  }

  @override
  String get adminBillingUnitInfo => 'Die Abrechnungseinheit (Impressionen pro Preis) wird automatisch anhand der aktiven Benutzer berechnet: Sie wächst mit der Plattform.';

  @override
  String get adminMinCampaign => 'Min. Kampagne';

  @override
  String get adminInvalidPrice => 'Ungültiger Preis';

  @override
  String get adminInvalidMinBudget => 'Ungültiges Mindestbudget';

  @override
  String get adminPricePerThousand => 'Preis pro 1.000 Impressionen (MXN)';

  @override
  String get adminPricePerSend => 'Preis pro Sendung (MXN)';

  @override
  String get adminFixedRate => 'Festpreis (MXN)';

  @override
  String get adminMinCampaignBudget => 'Mindestbudget der Kampagne (MXN)';

  @override
  String get adminSave => 'Speichern';

  @override
  String get adminCreditsTitle => 'Werbeguthaben';

  @override
  String get adminSearchEstOwner => 'Betrieb oder Inhaber suchen…';

  @override
  String get adminBalance => 'Guthaben';

  @override
  String get adminEnterValidAmount => 'Gib einen gültigen Betrag ein';

  @override
  String get adminEnterDescription => 'Schreibe eine Beschreibung';

  @override
  String adminCreditAdded(Object balance) {
    return 'Guthaben erfolgreich hinzugefügt. Neues Guthaben: $balance';
  }

  @override
  String adminCurrentBalance(Object balance) {
    return 'Aktuelles Guthaben: $balance';
  }

  @override
  String get adminAmountToAdd => 'Hinzuzufügender Betrag (MXN)';

  @override
  String get adminDescriptionReason => 'Beschreibung / Grund';

  @override
  String get adminSaving => 'Wird gespeichert…';

  @override
  String get adminAddCredit => 'Guthaben hinzufügen';

  @override
  String get adminBulkTitle => 'Superadmin-Massen-Upload';

  @override
  String get adminTabEstablishments => 'Betriebe';

  @override
  String get adminTabPromotions => 'Aktionen';

  @override
  String get adminCsvEmpty => 'Die CSV-Datei ist leer.';

  @override
  String get adminSelectOwner => 'Wähle einen Inhaber, bevor du fortfährst.';

  @override
  String get adminUploadCsvRow => 'Lade eine CSV mit mindestens einer Datenzeile hoch.';

  @override
  String adminRowEmptyName(Object row) {
    return 'Zeile $row: leerer Name';
  }

  @override
  String adminRowInvalidDays(Object row) {
    return 'Zeile $row: ungültige Tage (1-7 verwenden)';
  }

  @override
  String adminRowError(Object row, Object msg) {
    return 'Zeile $row: $msg';
  }

  @override
  String adminEstCreated(Object count) {
    return '$count Betrieb(e) erstellt';
  }

  @override
  String adminPromosCreated(Object count) {
    return '$count Aktion(en) erstellt · zählen nicht zum Plan';
  }

  @override
  String adminBulkEstBanner(Object count) {
    return 'Erstelle Betriebe für jeden Inhaber.\nDiese Sitzung: $count erstellt.';
  }

  @override
  String adminBulkPromoBanner(Object count) {
    return 'Erstelle Aktionen für jedes Unternehmen. Sie zählen nicht zum Planlimit.\nDiese Sitzung: $count erstellt.';
  }

  @override
  String get adminTemplateEstSubject => 'Promofy-Betriebsvorlage';

  @override
  String get adminTemplatePromoSubject => 'Promofy-Aktionsvorlage';

  @override
  String get adminDownloadCsvTemplate => 'CSV-Vorlage herunterladen';

  @override
  String get adminOwnerRequired => 'Inhaber *';

  @override
  String get adminSelectOwnerHint => 'Wähle einen Inhaber…';

  @override
  String get adminSelectCsvFile => 'CSV-Datei auswählen';

  @override
  String adminPreviewRows(Object count) {
    return 'Vorschau ($count Zeile(n)):';
  }

  @override
  String get adminCreatingEsts => 'Betriebe werden erstellt…';

  @override
  String adminCreateEstsBtn(Object count) {
    return '$count Betrieb(e) erstellen';
  }

  @override
  String get adminSelectEst => 'Wähle einen Betrieb.';

  @override
  String get adminEstRequired => 'Betrieb *';

  @override
  String get adminSelectBusinessHint => 'Wähle ein Unternehmen…';

  @override
  String get adminCreatingPromos => 'Aktionen werden erstellt…';

  @override
  String adminCreatePromosBtn(Object count) {
    return '$count Aktion(en) erstellen';
  }

  @override
  String get logrosTitle => 'Meine Erfolge';

  @override
  String get logrosLoadError => 'Deine Erfolge konnten nicht geladen werden.';

  @override
  String get logrosRetry => 'Erneut versuchen';

  @override
  String get logrosSectionVisits => 'Besuchsabzeichen';

  @override
  String get logrosSectionStreaks => 'Wöchentliche Serien';

  @override
  String logrosNextLevel(Object label) {
    return 'Nächste Stufe: $label';
  }

  @override
  String logrosAnnualVisits(Object count) {
    return '$count Besuche pro Jahr';
  }

  @override
  String logrosConsecutiveWeeks(Object count) {
    return '$count aufeinanderfolgende Wochen';
  }

  @override
  String logrosVisitsToGo(Object count) {
    return 'Noch $count Besuche, um es zu erreichen';
  }

  @override
  String get logrosStreakDescEnRacha => 'Du hast 3 Wochen in Folge Betriebe besucht';

  @override
  String get logrosStreakDescImparable => '8 Wochen ohne Pause — du bist unaufhaltsam';

  @override
  String get logrosStreakDescLeyenda => '26 Wochen (ein halbes Jahr) perfekte Serie';

  @override
  String get filterSheetTitle => 'Filter';

  @override
  String get filterSheetClearAll => 'Alle löschen';

  @override
  String get filterSheetSectionPlaceFeatures => 'Merkmale des Orts';

  @override
  String get filterSheetSectionCategory => 'Kategorie';

  @override
  String get filterSheetSectionFoodType => 'Art der Küche';

  @override
  String get filterSheetSectionDay => 'Tag';

  @override
  String get filterSheetSectionPaymentMethod => 'Zahlungsmethode';

  @override
  String get filterSheetApply => 'Filter anwenden';

  @override
  String filterSheetApplyWithCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Filter',
      one: 'Filter',
    );
    return 'Anwenden ($count $_temp0)';
  }

  @override
  String get filterChipsActiveNow => 'Jetzt aktiv';

  @override
  String get filterChipsFlash => '⚡ Blitz';

  @override
  String get filterChipsFavorites => '⭐ Meine Favoriten';

  @override
  String get filterChipsBirthday => '🎂 Geburtstag';

  @override
  String get filterChipsAdvancedMore => 'Mehr Filter';

  @override
  String filterChipsAdvancedCount(Object count) {
    return 'Filter ($count)';
  }

  @override
  String get adSplashAdLabel => 'Werbung';

  @override
  String adSplashPromoSpecial(Object name) {
    return 'Sonderangebot von $name';
  }

  @override
  String get adSplashDiscoverMsg => 'Tippe, um die exklusiven Angebote zu entdecken';

  @override
  String get adSplashViewPromos => 'Angebote ansehen';

  @override
  String get sponsoredCardBadge => 'Gesponsert';

  @override
  String get sponsoredCardSeePromotions => 'Ihre Angebote ansehen';

  @override
  String get sponsoredCardAd => 'Anzeige';

  @override
  String get adBannerSeePromotions => 'Ihre Angebote ansehen';

  @override
  String get adBannerAdLabel => 'Werbung';

  @override
  String get paymentResultGoHome => 'Zur Startseite';

  @override
  String get paymentResultTryAgain => 'Erneut versuchen';

  @override
  String get paymentResultSuccessTitle => 'Zahlung erfolgreich!';

  @override
  String get paymentResultSuccessSubtitle => 'Dein Guthaben an Werbe-Credits wird\nin Kürze in deinem Dashboard angezeigt.';

  @override
  String get paymentResultFailureTitle => 'Zahlung nicht abgeschlossen';

  @override
  String get paymentResultFailureSubtitle => 'Es wurde keine Abbuchung vorgenommen. Du kannst\njederzeit erneut versuchen.';

  @override
  String get paymentResultPendingTitle => 'Zahlung in Bearbeitung';

  @override
  String get paymentResultPendingSubtitle => 'Deine Zahlung wird verarbeitet.\nWir benachrichtigen dich, sobald sie bestätigt ist.';

  @override
  String get paymentResultSubscriptionTitle => 'Abonnement aktiviert!';

  @override
  String get paymentResultSubscriptionSubtitle => 'Dein Promofy-Plan ist jetzt aktiv.\nGenieße alle Funktionen für dein Unternehmen.';

  @override
  String get locationPermTitle => 'Angebote warten\nganz in deiner Nähe!';

  @override
  String get locationPermSubtitle => 'Teile deinen Standort, um sofort\ndie besten Angebote nach Entfernung\nsortiert zu sehen.';

  @override
  String get locationPermAllowButton => 'Standort erlauben';

  @override
  String get locationPermSkipButton => 'Jetzt nicht';

  @override
  String get splashScrTagline => 'Entdecke Angebote in deiner Nähe';

  @override
  String get settingsMyFavs => 'Meine Favs';

  @override
  String get tourSkip => 'Überspringen';

  @override
  String get tourNext => 'Weiter';

  @override
  String get tourStart => 'Los geht\'s';

  @override
  String get tourReplay => 'Tutorial ansehen';

  @override
  String get tour1Title => 'Willkommen bei Promofy!';

  @override
  String get tour1Desc => 'Entdecke die besten Angebote von Restaurants und Unterhaltung in deiner Nähe.';

  @override
  String get tour2Title => 'Entdecke in deiner Nähe';

  @override
  String get tour2Desc => 'Unter Start und Orte findest du Angebote und Betriebe nach Entfernung sortiert. Nutze Filter, um genau das zu finden, worauf du Lust hast.';

  @override
  String get tour3Title => 'Blitzangebote';

  @override
  String get tour3Desc => 'Zeitlich begrenzte Angebote. Schnapp sie dir, bevor sie weg sind!';

  @override
  String get tour4Title => 'Treuestempel';

  @override
  String get tour4Desc => 'Zeige bei jedem Besuch deinen QR-Code, sammle Stempel und erhalte Belohnungen an deinen Lieblingsorten.';

  @override
  String get tour5Title => 'Favoriten & Geburtstag';

  @override
  String get tour5Desc => 'Speichere deine Lieblingsangebote mit dem Herz und erhalte ein besonderes Geschenk zu deinem Geburtstag.';

  @override
  String get ownerTour1Title => 'Du bist jetzt ein Promofy-Betrieb!';

  @override
  String get ownerTour1Desc => 'Verwalte alles über den Tab «Mein Betrieb»: deine Lokale, Angebote, Werbung und Statistiken.';

  @override
  String get ownerTour2Title => 'Angebote erstellen';

  @override
  String get ownerTour2Desc => 'Veröffentliche normale, Blitz- und Geburtstagsangebote und richte dein Treuestempel-Programm ein.';

  @override
  String get ownerTour3Title => 'Einlösungen per QR prüfen';

  @override
  String get ownerTour3Desc => 'Scanne den Code des Kunden, um seine Angebote zu validieren und Treuebesuche zu erfassen.';

  @override
  String get ownerTour4Title => 'Mehr Kunden gewinnen';

  @override
  String get ownerTour4Desc => 'Erstelle Werbekampagnen (Splash, Banner, Hervorhebung und Benachrichtigungen), um mehr Leute in deiner Nähe zu erreichen.';

  @override
  String get ownerTour5Title => 'Messen und wachsen';

  @override
  String get ownerTour5Desc => 'Sieh dir deine Statistiken und den Durchschnittsbon an und verwalte deinen Plan und Add-ons bei Bedarf.';
}
