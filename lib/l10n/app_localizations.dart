import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageAuto.
  ///
  /// In es, this message translates to:
  /// **'Automático (del dispositivo)'**
  String get languageAuto;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @explore.
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get explore;

  /// No description provided for @favTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis favoritos'**
  String get favTitle;

  /// No description provided for @favTabPromos.
  ///
  /// In es, this message translates to:
  /// **'Promociones'**
  String get favTabPromos;

  /// No description provided for @favTabEstablishments.
  ///
  /// In es, this message translates to:
  /// **'Establecimientos'**
  String get favTabEstablishments;

  /// No description provided for @favEmptyPromosTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes promos favoritas'**
  String get favEmptyPromosTitle;

  /// No description provided for @favEmptyPromosSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Toca el corazón en cualquier promo\npara guardarla aquí'**
  String get favEmptyPromosSubtitle;

  /// No description provided for @favEmptyEstTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes negocios favoritos'**
  String get favEmptyEstTitle;

  /// No description provided for @favEmptyEstSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Entra a un negocio y toca el corazón\npara guardarlo aquí'**
  String get favEmptyEstSubtitle;

  /// No description provided for @removeFromFavorites.
  ///
  /// In es, this message translates to:
  /// **'Quitar de favoritos'**
  String get removeFromFavorites;

  /// No description provided for @loginWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Promofy'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Descubre promociones cerca de ti'**
  String get loginSubtitle;

  /// No description provided for @loginContinueGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get loginContinueGoogle;

  /// No description provided for @loginOr.
  ///
  /// In es, this message translates to:
  /// **'o'**
  String get loginOr;

  /// No description provided for @loginEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailEmpty.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo'**
  String get loginEmailEmpty;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Correo no válido'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordEmpty.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get loginPasswordEmpty;

  /// No description provided for @loginPasswordMinLength.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get loginPasswordMinLength;

  /// No description provided for @loginForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get loginForgotPassword;

  /// No description provided for @loginSignInButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginSignInButton;

  /// No description provided for @loginSignUpButton.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get loginSignUpButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get loginNoAccount;

  /// No description provided for @loginHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? '**
  String get loginHaveAccount;

  /// No description provided for @loginSignUpLink.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get loginSignUpLink;

  /// No description provided for @loginSignInLink.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get loginSignInLink;

  /// No description provided for @loginResetInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido.'**
  String get loginResetInvalidEmail;

  /// No description provided for @loginResetTitle.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get loginResetTitle;

  /// No description provided for @loginResetDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get loginResetDone;

  /// No description provided for @loginResetCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get loginResetCancel;

  /// No description provided for @loginResetSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get loginResetSend;

  /// No description provided for @loginResetDescription.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un enlace para restablecer tu contraseña.'**
  String get loginResetDescription;

  /// No description provided for @loginResetEmailHint.
  ///
  /// In es, this message translates to:
  /// **'tu@correo.com'**
  String get loginResetEmailHint;

  /// No description provided for @loginResetSuccessTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Correo enviado!'**
  String get loginResetSuccessTitle;

  /// No description provided for @loginResetSuccessBody.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu bandeja de entrada y sigue las instrucciones.'**
  String get loginResetSuccessBody;

  /// No description provided for @loginResetSpamHint.
  ///
  /// In es, this message translates to:
  /// **'Si no llega en unos minutos, revisa la carpeta de spam.'**
  String get loginResetSpamHint;

  /// No description provided for @onboardingTitle.
  ///
  /// In es, this message translates to:
  /// **'Completa tu perfil'**
  String get onboardingTitle;

  /// No description provided for @onboardingExit.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get onboardingExit;

  /// No description provided for @onboardingHeading.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos sobre ti'**
  String get onboardingHeading;

  /// No description provided for @onboardingAdultOnlyNotice.
  ///
  /// In es, this message translates to:
  /// **'Promofy es exclusivo para mayores de 18 años'**
  String get onboardingAdultOnlyNotice;

  /// No description provided for @onboardingNameQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cuál es tu nombre?'**
  String get onboardingNameQuestion;

  /// No description provided for @onboardingNameHint.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre completo'**
  String get onboardingNameHint;

  /// No description provided for @onboardingNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nombre'**
  String get onboardingNameRequired;

  /// No description provided for @onboardingBirthQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cuándo naciste?'**
  String get onboardingBirthQuestion;

  /// No description provided for @onboardingSelectBirthDate.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu fecha de nacimiento'**
  String get onboardingSelectBirthDate;

  /// No description provided for @onboardingGenderQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cuál es tu sexo?'**
  String get onboardingGenderQuestion;

  /// No description provided for @onboardingGenderMale.
  ///
  /// In es, this message translates to:
  /// **'Masculino'**
  String get onboardingGenderMale;

  /// No description provided for @onboardingGenderFemale.
  ///
  /// In es, this message translates to:
  /// **'Femenino'**
  String get onboardingGenderFemale;

  /// No description provided for @onboardingGenderPreferNot.
  ///
  /// In es, this message translates to:
  /// **'Prefiero no decir'**
  String get onboardingGenderPreferNot;

  /// No description provided for @onboardingSubmit.
  ///
  /// In es, this message translates to:
  /// **'Completar mi perfil'**
  String get onboardingSubmit;

  /// No description provided for @onboardingMustBeAdult.
  ///
  /// In es, this message translates to:
  /// **'Debes ser mayor de 18 años'**
  String get onboardingMustBeAdult;

  /// No description provided for @onboardingConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get onboardingConfirm;

  /// No description provided for @onboardingCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get onboardingCancel;

  /// No description provided for @onboardingMustBeAdultToUse.
  ///
  /// In es, this message translates to:
  /// **'Debes ser mayor de 18 años para usar Promofy'**
  String get onboardingMustBeAdultToUse;

  /// No description provided for @onboardingSelectGender.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu género'**
  String get onboardingSelectGender;

  /// No description provided for @resetPwdAppBarTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get resetPwdAppBarTitle;

  /// No description provided for @resetPwdUpdateError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo actualizar la contraseña.'**
  String get resetPwdUpdateError;

  /// No description provided for @resetPwdSuccessTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Contraseña actualizada!'**
  String get resetPwdSuccessTitle;

  /// No description provided for @resetPwdSuccessSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ya puedes iniciar sesión\ncon tu nueva contraseña.'**
  String get resetPwdSuccessSubtitle;

  /// No description provided for @resetPwdGoHome.
  ///
  /// In es, this message translates to:
  /// **'Ir al inicio'**
  String get resetPwdGoHome;

  /// No description provided for @resetPwdFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu nueva contraseña'**
  String get resetPwdFormTitle;

  /// No description provided for @resetPwdFormHint.
  ///
  /// In es, this message translates to:
  /// **'Debe tener al menos 6 caracteres.'**
  String get resetPwdFormHint;

  /// No description provided for @resetPwdNewLabel.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get resetPwdNewLabel;

  /// No description provided for @resetPwdMinLength.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get resetPwdMinLength;

  /// No description provided for @resetPwdConfirmLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get resetPwdConfirmLabel;

  /// No description provided for @resetPwdMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get resetPwdMismatch;

  /// No description provided for @resetPwdSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar contraseña'**
  String get resetPwdSave;

  /// No description provided for @homeSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar promo o restaurante...'**
  String get homeSearchHint;

  /// No description provided for @homeEmptySearch.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados para \"{query}\"'**
  String homeEmptySearch(Object query);

  /// No description provided for @homeEmptyFilters.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados para estos filtros'**
  String get homeEmptyFilters;

  /// No description provided for @homeEmptyNoPromos.
  ///
  /// In es, this message translates to:
  /// **'No hay promociones por aquí aún'**
  String get homeEmptyNoPromos;

  /// No description provided for @homeClearSearchAndFilters.
  ///
  /// In es, this message translates to:
  /// **'Limpiar búsqueda y filtros'**
  String get homeClearSearchAndFilters;

  /// No description provided for @homeRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get homeRetry;

  /// No description provided for @promoDetailNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo'**
  String get promoDetailNew;

  /// No description provided for @promoDetailBirthdayGift.
  ///
  /// In es, this message translates to:
  /// **'Tu regalo de cumpleaños'**
  String get promoDetailBirthdayGift;

  /// No description provided for @promoDetailConditions.
  ///
  /// In es, this message translates to:
  /// **'Condiciones: {terms}'**
  String promoDetailConditions(Object terms);

  /// No description provided for @promoDetailDescription.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get promoDetailDescription;

  /// No description provided for @promoDetailAvailability.
  ///
  /// In es, this message translates to:
  /// **'Disponibilidad'**
  String get promoDetailAvailability;

  /// No description provided for @promoDetailShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get promoDetailShare;

  /// No description provided for @promoDetailSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardado'**
  String get promoDetailSaved;

  /// No description provided for @promoDetailSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get promoDetailSave;

  /// No description provided for @promoDetailFlash.
  ///
  /// In es, this message translates to:
  /// **'⚡ Relámpago'**
  String get promoDetailFlash;

  /// No description provided for @promoDetailFlashEndsInHours.
  ///
  /// In es, this message translates to:
  /// **'⚡ Termina en {hours}h {minutes}m'**
  String promoDetailFlashEndsInHours(Object hours, Object minutes);

  /// No description provided for @promoDetailFlashEndsInMinutes.
  ///
  /// In es, this message translates to:
  /// **'⚡ Termina en {minutes}m'**
  String promoDetailFlashEndsInMinutes(Object minutes);

  /// No description provided for @restaurantNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo'**
  String get restaurantNew;

  /// No description provided for @restaurantTypeUrbanMobile.
  ///
  /// In es, this message translates to:
  /// **'Urbano / Móvil'**
  String get restaurantTypeUrbanMobile;

  /// No description provided for @restaurantTypeLocal.
  ///
  /// In es, this message translates to:
  /// **'Local'**
  String get restaurantTypeLocal;

  /// No description provided for @restaurantCall.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get restaurantCall;

  /// No description provided for @restaurantWebsite.
  ///
  /// In es, this message translates to:
  /// **'Web'**
  String get restaurantWebsite;

  /// No description provided for @restaurantCharacteristics.
  ///
  /// In es, this message translates to:
  /// **'Características'**
  String get restaurantCharacteristics;

  /// No description provided for @restaurantPaymentMethods.
  ///
  /// In es, this message translates to:
  /// **'Métodos de pago'**
  String get restaurantPaymentMethods;

  /// No description provided for @restaurantSchedule.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get restaurantSchedule;

  /// No description provided for @restaurantClosed.
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get restaurantClosed;

  /// No description provided for @restaurantLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get restaurantLocation;

  /// No description provided for @restaurantViewOnMap.
  ///
  /// In es, this message translates to:
  /// **'Ver en mapa'**
  String get restaurantViewOnMap;

  /// No description provided for @restaurantGetDirections.
  ///
  /// In es, this message translates to:
  /// **'Cómo llegar'**
  String get restaurantGetDirections;

  /// No description provided for @restaurantPhotos.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get restaurantPhotos;

  /// No description provided for @restaurantLoyaltyProgram.
  ///
  /// In es, this message translates to:
  /// **'Programa de lealtad'**
  String get restaurantLoyaltyProgram;

  /// No description provided for @restaurantVisitsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} visitas'**
  String restaurantVisitsCount(Object count);

  /// No description provided for @restaurantValidUntil.
  ///
  /// In es, this message translates to:
  /// **'Vigente hasta {date} · {days} días'**
  String restaurantValidUntil(Object date, Object days);

  /// No description provided for @restaurantEnded.
  ///
  /// In es, this message translates to:
  /// **'Terminó {date}'**
  String restaurantEnded(Object date);

  /// No description provided for @restaurantViewStampsAndQr.
  ///
  /// In es, this message translates to:
  /// **'Ver mis sellos y QR'**
  String get restaurantViewStampsAndQr;

  /// No description provided for @restaurantActivePromos.
  ///
  /// In es, this message translates to:
  /// **'Promociones activas'**
  String get restaurantActivePromos;

  /// No description provided for @restaurantNoActivePromos.
  ///
  /// In es, this message translates to:
  /// **'Sin promociones activas por ahora.'**
  String get restaurantNoActivePromos;

  /// No description provided for @restaurantNoPromosToday.
  ///
  /// In es, this message translates to:
  /// **'Sin promociones para hoy.'**
  String get restaurantNoPromosToday;

  /// No description provided for @restaurantAlsoThisWeek.
  ///
  /// In es, this message translates to:
  /// **'También esta semana'**
  String get restaurantAlsoThisWeek;

  /// No description provided for @restaurantFlash.
  ///
  /// In es, this message translates to:
  /// **'Flash'**
  String get restaurantFlash;

  /// No description provided for @restaurantRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get restaurantRetry;

  /// No description provided for @lugaresSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar negocio...'**
  String get lugaresSearchHint;

  /// No description provided for @lugaresChipOpenNow.
  ///
  /// In es, this message translates to:
  /// **'Abiertos ahora'**
  String get lugaresChipOpenNow;

  /// No description provided for @lugaresChipFlash.
  ///
  /// In es, this message translates to:
  /// **'⚡ Relámpago'**
  String get lugaresChipFlash;

  /// No description provided for @lugaresChipFavorites.
  ///
  /// In es, this message translates to:
  /// **'⭐ Mis favoritos'**
  String get lugaresChipFavorites;

  /// No description provided for @lugaresChipMoreFilters.
  ///
  /// In es, this message translates to:
  /// **'Más filtros'**
  String get lugaresChipMoreFilters;

  /// No description provided for @lugaresChipFiltersCount.
  ///
  /// In es, this message translates to:
  /// **'Filtros ({count})'**
  String lugaresChipFiltersCount(Object count);

  /// No description provided for @lugaresFiltersTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get lugaresFiltersTitle;

  /// No description provided for @lugaresClearAll.
  ///
  /// In es, this message translates to:
  /// **'Limpiar todo'**
  String get lugaresClearAll;

  /// No description provided for @lugaresSectionCharacteristics.
  ///
  /// In es, this message translates to:
  /// **'Características del lugar'**
  String get lugaresSectionCharacteristics;

  /// No description provided for @lugaresSectionCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get lugaresSectionCategory;

  /// No description provided for @lugaresSectionDay.
  ///
  /// In es, this message translates to:
  /// **'Día'**
  String get lugaresSectionDay;

  /// No description provided for @lugaresSectionPayment.
  ///
  /// In es, this message translates to:
  /// **'Método de pago'**
  String get lugaresSectionPayment;

  /// No description provided for @lugaresDayMon.
  ///
  /// In es, this message translates to:
  /// **'Lun'**
  String get lugaresDayMon;

  /// No description provided for @lugaresDayTue.
  ///
  /// In es, this message translates to:
  /// **'Mar'**
  String get lugaresDayTue;

  /// No description provided for @lugaresDayWed.
  ///
  /// In es, this message translates to:
  /// **'Mié'**
  String get lugaresDayWed;

  /// No description provided for @lugaresDayThu.
  ///
  /// In es, this message translates to:
  /// **'Jue'**
  String get lugaresDayThu;

  /// No description provided for @lugaresDayFri.
  ///
  /// In es, this message translates to:
  /// **'Vie'**
  String get lugaresDayFri;

  /// No description provided for @lugaresDaySat.
  ///
  /// In es, this message translates to:
  /// **'Sáb'**
  String get lugaresDaySat;

  /// No description provided for @lugaresDaySun.
  ///
  /// In es, this message translates to:
  /// **'Dom'**
  String get lugaresDaySun;

  /// No description provided for @lugaresPaymentCash.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get lugaresPaymentCash;

  /// No description provided for @lugaresPaymentCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta'**
  String get lugaresPaymentCard;

  /// No description provided for @lugaresPaymentTransfer.
  ///
  /// In es, this message translates to:
  /// **'Transferencia'**
  String get lugaresPaymentTransfer;

  /// No description provided for @lugaresPaymentMercadopago.
  ///
  /// In es, this message translates to:
  /// **'MercadoPago'**
  String get lugaresPaymentMercadopago;

  /// No description provided for @lugaresApplyWithCount.
  ///
  /// In es, this message translates to:
  /// **'Aplicar ({count} {count, plural, one {filtro} other {filtros}})'**
  String lugaresApplyWithCount(num count);

  /// No description provided for @lugaresApplyFilters.
  ///
  /// In es, this message translates to:
  /// **'Aplicar filtros'**
  String get lugaresApplyFilters;

  /// No description provided for @lugaresEmptyFiltered.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados para los filtros aplicados'**
  String get lugaresEmptyFiltered;

  /// No description provided for @lugaresEmptyNoNearby.
  ///
  /// In es, this message translates to:
  /// **'No hay negocios cerca por ahora'**
  String get lugaresEmptyNoNearby;

  /// No description provided for @lugaresClearFilters.
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtros'**
  String get lugaresClearFilters;

  /// No description provided for @lugaresRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get lugaresRetry;

  /// No description provided for @stampsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Sellos'**
  String get stampsTitle;

  /// No description provided for @stampsMyQrTooltip.
  ///
  /// In es, this message translates to:
  /// **'Mi QR de visitas'**
  String get stampsMyQrTooltip;

  /// No description provided for @stampsSectionReady.
  ///
  /// In es, this message translates to:
  /// **'Recompensas listas para canjear'**
  String get stampsSectionReady;

  /// No description provided for @stampsSectionInProgress.
  ///
  /// In es, this message translates to:
  /// **'En progreso'**
  String get stampsSectionInProgress;

  /// No description provided for @stampsSuffixProgram.
  ///
  /// In es, this message translates to:
  /// **'programa'**
  String get stampsSuffixProgram;

  /// No description provided for @stampsSuffixPrograms.
  ///
  /// In es, this message translates to:
  /// **'programas'**
  String get stampsSuffixPrograms;

  /// No description provided for @stampsSectionEarned.
  ///
  /// In es, this message translates to:
  /// **'Recompensas ganadas'**
  String get stampsSectionEarned;

  /// No description provided for @stampsSuffixTotal.
  ///
  /// In es, this message translates to:
  /// **'totales'**
  String get stampsSuffixTotal;

  /// No description provided for @stampsSeeAllRewards.
  ///
  /// In es, this message translates to:
  /// **'Ver todas las recompensas →'**
  String get stampsSeeAllRewards;

  /// No description provided for @stampsTapForRedemptionQr.
  ///
  /// In es, this message translates to:
  /// **'Toca para ver QR de canje'**
  String get stampsTapForRedemptionQr;

  /// No description provided for @stampsReadyBadge.
  ///
  /// In es, this message translates to:
  /// **'¡LISTA!'**
  String get stampsReadyBadge;

  /// No description provided for @stampsFinished.
  ///
  /// In es, this message translates to:
  /// **'Terminado'**
  String get stampsFinished;

  /// No description provided for @stampsVisitsCount.
  ///
  /// In es, this message translates to:
  /// **'{visits}/{required} visitas'**
  String stampsVisitsCount(Object visits, Object required);

  /// No description provided for @stampsStampsLeft.
  ///
  /// In es, this message translates to:
  /// **'¡Te faltan {count}! 🔥'**
  String stampsStampsLeft(Object count);

  /// No description provided for @stampsExpiredOn.
  ///
  /// In es, this message translates to:
  /// **'Venció el {date}'**
  String stampsExpiredOn(Object date);

  /// No description provided for @stampsExpiresOn.
  ///
  /// In es, this message translates to:
  /// **'Caduca el {date}'**
  String stampsExpiresOn(Object date);

  /// No description provided for @stampsRedeemed.
  ///
  /// In es, this message translates to:
  /// **'Canjeada'**
  String get stampsRedeemed;

  /// No description provided for @stampsRedeemReward.
  ///
  /// In es, this message translates to:
  /// **'Canjear recompensa'**
  String get stampsRedeemReward;

  /// No description provided for @stampsAtEstablishment.
  ///
  /// In es, this message translates to:
  /// **'en {name}'**
  String stampsAtEstablishment(Object name);

  /// No description provided for @stampsCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código: {code}'**
  String stampsCodeLabel(Object code);

  /// No description provided for @stampsShowCodeToStaff.
  ///
  /// In es, this message translates to:
  /// **'Muestra este código al personal'**
  String get stampsShowCodeToStaff;

  /// No description provided for @stampsStaffWillScan.
  ///
  /// In es, this message translates to:
  /// **'Lo escanearán para validar tu recompensa'**
  String get stampsStaffWillScan;

  /// No description provided for @stampsMyQrTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi código QR'**
  String get stampsMyQrTitle;

  /// No description provided for @stampsMyQrSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Muéstrale este código al negocio para registrar tu visita.'**
  String get stampsMyQrSubtitle;

  /// No description provided for @stampsUniqueAccountCode.
  ///
  /// In es, this message translates to:
  /// **'Código único de tu cuenta'**
  String get stampsUniqueAccountCode;

  /// No description provided for @stampsRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get stampsRetry;

  /// No description provided for @stampsEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes sellos'**
  String get stampsEmptyTitle;

  /// No description provided for @stampsEmptyMsg.
  ///
  /// In es, this message translates to:
  /// **'Visita negocios con programa de lealtad y muéstrales tu código QR para acumular sellos.'**
  String get stampsEmptyMsg;

  /// No description provided for @stampsViewMyQr.
  ///
  /// In es, this message translates to:
  /// **'Ver mi QR'**
  String get stampsViewMyQr;

  /// No description provided for @loyaltyTitle.
  ///
  /// In es, this message translates to:
  /// **'Programa de lealtad'**
  String get loyaltyTitle;

  /// No description provided for @loyaltyScan.
  ///
  /// In es, this message translates to:
  /// **'Escanear'**
  String get loyaltyScan;

  /// No description provided for @loyaltyStatusDeactivated.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get loyaltyStatusDeactivated;

  /// No description provided for @loyaltyStatusExpired.
  ///
  /// In es, this message translates to:
  /// **'Venció el {date}'**
  String loyaltyStatusExpired(Object date);

  /// No description provided for @loyaltyStatusExpiresIn.
  ///
  /// In es, this message translates to:
  /// **'{days, plural, one{Vence en {days} día} other{Vence en {days} días}}'**
  String loyaltyStatusExpiresIn(num days);

  /// No description provided for @loyaltyStatusActive.
  ///
  /// In es, this message translates to:
  /// **'Activo — termina {date}'**
  String loyaltyStatusActive(Object date);

  /// No description provided for @loyaltyVisitsRequired.
  ///
  /// In es, this message translates to:
  /// **'Visitas requeridas'**
  String get loyaltyVisitsRequired;

  /// No description provided for @loyaltyReward.
  ///
  /// In es, this message translates to:
  /// **'Premio'**
  String get loyaltyReward;

  /// No description provided for @loyaltyStart.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get loyaltyStart;

  /// No description provided for @loyaltyEnd.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get loyaltyEnd;

  /// No description provided for @loyaltyEndNow.
  ///
  /// In es, this message translates to:
  /// **'Terminar programa ahora'**
  String get loyaltyEndNow;

  /// No description provided for @loyaltyCreateNew.
  ///
  /// In es, this message translates to:
  /// **'Crear nuevo programa'**
  String get loyaltyCreateNew;

  /// No description provided for @loyaltyEndDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Terminar programa?'**
  String get loyaltyEndDialogTitle;

  /// No description provided for @loyaltyEndDialogContent.
  ///
  /// In es, this message translates to:
  /// **'Todos los clientes dejarán de acumular visitas en este programa. Podrás crear uno nuevo cuando quieras.'**
  String get loyaltyEndDialogContent;

  /// No description provided for @loyaltyCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get loyaltyCancel;

  /// No description provided for @loyaltyEnd2.
  ///
  /// In es, this message translates to:
  /// **'Terminar'**
  String get loyaltyEnd2;

  /// No description provided for @loyaltyNoProgramDesc.
  ///
  /// In es, this message translates to:
  /// **'Fideliza a tus clientes con un sistema de sellos digital. Define cuántas visitas necesitan para ganar su premio.'**
  String get loyaltyNoProgramDesc;

  /// No description provided for @loyaltyCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear programa'**
  String get loyaltyCreate;

  /// No description provided for @loyaltyParticipants.
  ///
  /// In es, this message translates to:
  /// **'Participantes'**
  String get loyaltyParticipants;

  /// No description provided for @loyaltyRewardWon.
  ///
  /// In es, this message translates to:
  /// **'Premio ganado'**
  String get loyaltyRewardWon;

  /// No description provided for @loyaltyViewClients.
  ///
  /// In es, this message translates to:
  /// **'Ver clientes'**
  String get loyaltyViewClients;

  /// No description provided for @loyaltyClientsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis clientes'**
  String get loyaltyClientsTitle;

  /// No description provided for @loyaltyClientsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los clientes.'**
  String get loyaltyClientsLoadError;

  /// No description provided for @loyaltyClientsRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get loyaltyClientsRetry;

  /// No description provided for @loyaltyClientsCurrentProgram.
  ///
  /// In es, this message translates to:
  /// **'PROGRAMA ACTUAL'**
  String get loyaltyClientsCurrentProgram;

  /// No description provided for @loyaltyClientsParticipants.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{count} participante} other{{count} participantes}}'**
  String loyaltyClientsParticipants(num count);

  /// No description provided for @loyaltyClientsEmptyProgram.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay clientes en este programa. Escanea el QR de tus primeros visitantes.'**
  String get loyaltyClientsEmptyProgram;

  /// No description provided for @loyaltyClientsReward.
  ///
  /// In es, this message translates to:
  /// **'¡Premio!'**
  String get loyaltyClientsReward;

  /// No description provided for @loyaltyClientsStampsLeft.
  ///
  /// In es, this message translates to:
  /// **'{count} para su premio'**
  String loyaltyClientsStampsLeft(Object count);

  /// No description provided for @loyaltyClientsHistoryHeader.
  ///
  /// In es, this message translates to:
  /// **'HISTORIAL DE COMENSALES'**
  String get loyaltyClientsHistoryHeader;

  /// No description provided for @loyaltyClientsHistorySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Total de visitas registradas con QR, de mayor a menor.'**
  String get loyaltyClientsHistorySubtitle;

  /// No description provided for @loyaltyClientsEmptyHistory.
  ///
  /// In es, this message translates to:
  /// **'El historial aparecerá aquí conforme escanees a tus clientes con QR.'**
  String get loyaltyClientsEmptyHistory;

  /// No description provided for @loyaltyClientsColumnClient.
  ///
  /// In es, this message translates to:
  /// **'Cliente'**
  String get loyaltyClientsColumnClient;

  /// No description provided for @loyaltyClientsColumnVisits.
  ///
  /// In es, this message translates to:
  /// **'Visitas'**
  String get loyaltyClientsColumnVisits;

  /// No description provided for @loyaltyClientsColumnSpent.
  ///
  /// In es, this message translates to:
  /// **'Gasto'**
  String get loyaltyClientsColumnSpent;

  /// No description provided for @loyaltyClientsColumnLast.
  ///
  /// In es, this message translates to:
  /// **'Última'**
  String get loyaltyClientsColumnLast;

  /// No description provided for @qrInvalidCode.
  ///
  /// In es, this message translates to:
  /// **'QR no válido. Pide al cliente que muestre su código.'**
  String get qrInvalidCode;

  /// No description provided for @qrScanTitle.
  ///
  /// In es, this message translates to:
  /// **'Escanear cliente'**
  String get qrScanTitle;

  /// No description provided for @qrTorch.
  ///
  /// In es, this message translates to:
  /// **'Linterna'**
  String get qrTorch;

  /// No description provided for @qrPointInstruction.
  ///
  /// In es, this message translates to:
  /// **'Apunta al QR del cliente'**
  String get qrPointInstruction;

  /// No description provided for @qrErrorUnauthorized.
  ///
  /// In es, this message translates to:
  /// **'No tienes permiso para registrar visitas en este programa.'**
  String get qrErrorUnauthorized;

  /// No description provided for @qrErrorProgramInactive.
  ///
  /// In es, this message translates to:
  /// **'El programa está inactivo o venció.'**
  String get qrErrorProgramInactive;

  /// No description provided for @qrErrorNetwork.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión. Intenta de nuevo.'**
  String get qrErrorNetwork;

  /// No description provided for @qrErrorUnexpected.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado.'**
  String get qrErrorUnexpected;

  /// No description provided for @qrCouldNotRegister.
  ///
  /// In es, this message translates to:
  /// **'No se pudo registrar'**
  String get qrCouldNotRegister;

  /// No description provided for @qrRewardWonTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Premio ganado! 🎉'**
  String get qrRewardWonTitle;

  /// No description provided for @qrRewardWonMessage.
  ///
  /// In es, this message translates to:
  /// **'El cliente completó {visits} visitas. ¡Es momento de entregarle su regalo!'**
  String qrRewardWonMessage(Object visits);

  /// No description provided for @qrVisitRegistered.
  ///
  /// In es, this message translates to:
  /// **'Visita registrada'**
  String get qrVisitRegistered;

  /// No description provided for @qrVisitsLeft.
  ///
  /// In es, this message translates to:
  /// **'Al cliente le faltan {count} visita(s) para su premio.'**
  String qrVisitsLeft(Object count);

  /// No description provided for @qrProgramCompleted.
  ///
  /// In es, this message translates to:
  /// **'¡Completó el programa!'**
  String get qrProgramCompleted;

  /// No description provided for @qrBillAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Importe de la cuenta (opcional)'**
  String get qrBillAmountLabel;

  /// No description provided for @qrBillAmountHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 350'**
  String get qrBillAmountHint;

  /// No description provided for @qrBillAmountHelper.
  ///
  /// In es, this message translates to:
  /// **'Registra cuánto gastó el cliente para medir el ROI de Promofy.'**
  String get qrBillAmountHelper;

  /// No description provided for @qrDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get qrDone;

  /// No description provided for @qrVisitsCount.
  ///
  /// In es, this message translates to:
  /// **'{current}/{total} visitas'**
  String qrVisitsCount(Object current, Object total);

  /// No description provided for @loyaltyFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo programa de lealtad'**
  String get loyaltyFormTitle;

  /// No description provided for @loyaltyFormInfo.
  ///
  /// In es, this message translates to:
  /// **'El cliente muestra su QR, tú lo escaneas en cada visita. Al completar el número de visitas, recibirá su premio. Cuando el programa termine puedes crear uno nuevo y todos los contadores se reinician.'**
  String get loyaltyFormInfo;

  /// No description provided for @loyaltyFormVisitsLabel.
  ///
  /// In es, this message translates to:
  /// **'Visitas para ganar el premio'**
  String get loyaltyFormVisitsLabel;

  /// No description provided for @loyaltyFormVisitsHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 5'**
  String get loyaltyFormVisitsHint;

  /// No description provided for @loyaltyFormVisitsSuffix.
  ///
  /// In es, this message translates to:
  /// **'visitas'**
  String get loyaltyFormVisitsSuffix;

  /// No description provided for @loyaltyFormVisitsMin.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 2 visitas'**
  String get loyaltyFormVisitsMin;

  /// No description provided for @loyaltyFormVisitsMax.
  ///
  /// In es, this message translates to:
  /// **'Máximo 50 visitas'**
  String get loyaltyFormVisitsMax;

  /// No description provided for @loyaltyFormRewardLabel.
  ///
  /// In es, this message translates to:
  /// **'¿Qué gana el cliente?'**
  String get loyaltyFormRewardLabel;

  /// No description provided for @loyaltyFormRewardHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Café gratis, 20% de descuento, postre gratis…'**
  String get loyaltyFormRewardHint;

  /// No description provided for @loyaltyFormRewardRequired.
  ///
  /// In es, this message translates to:
  /// **'Describe el premio'**
  String get loyaltyFormRewardRequired;

  /// No description provided for @loyaltyFormValidityLabel.
  ///
  /// In es, this message translates to:
  /// **'Vigencia del programa'**
  String get loyaltyFormValidityLabel;

  /// No description provided for @loyaltyFormStartLabel.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get loyaltyFormStartLabel;

  /// No description provided for @loyaltyFormEndLabel.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get loyaltyFormEndLabel;

  /// No description provided for @loyaltyFormSelectDate.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar'**
  String get loyaltyFormSelectDate;

  /// No description provided for @loyaltyFormSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get loyaltyFormSaving;

  /// No description provided for @loyaltyFormSubmit.
  ///
  /// In es, this message translates to:
  /// **'Activar programa'**
  String get loyaltyFormSubmit;

  /// No description provided for @loyaltyFormSelectEndDate.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la fecha de fin del programa.'**
  String get loyaltyFormSelectEndDate;

  /// No description provided for @loyaltyFormCreateError.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el programa. Intenta de nuevo.'**
  String get loyaltyFormCreateError;

  /// No description provided for @plansWebviewSubscriptionTitle.
  ///
  /// In es, this message translates to:
  /// **'Suscripción Promofy'**
  String get plansWebviewSubscriptionTitle;

  /// No description provided for @plansWebviewAddonTitle.
  ///
  /// In es, this message translates to:
  /// **'Comprar add-on'**
  String get plansWebviewAddonTitle;

  /// No description provided for @plansAppBarTitle.
  ///
  /// In es, this message translates to:
  /// **'Planes y pagos'**
  String get plansAppBarTitle;

  /// No description provided for @plansRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get plansRetry;

  /// No description provided for @plansPaymentApprovedTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Pago aprobado!'**
  String get plansPaymentApprovedTitle;

  /// No description provided for @plansPaymentPendingTitle.
  ///
  /// In es, this message translates to:
  /// **'Pago en proceso'**
  String get plansPaymentPendingTitle;

  /// No description provided for @plansPaymentApprovedBody.
  ///
  /// In es, this message translates to:
  /// **'Tu suscripción fue activada correctamente. Ya puedes disfrutar de todos los beneficios de tu plan.'**
  String get plansPaymentApprovedBody;

  /// No description provided for @plansPaymentPendingBody.
  ///
  /// In es, this message translates to:
  /// **'Tu pago está siendo procesado. En cuanto se confirme, tu plan se actualizará automáticamente.'**
  String get plansPaymentPendingBody;

  /// No description provided for @plansGotIt.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get plansGotIt;

  /// No description provided for @plansLaunchPromoTitle.
  ///
  /// In es, this message translates to:
  /// **'Promoción de Lanzamiento'**
  String get plansLaunchPromoTitle;

  /// No description provided for @plansLaunchPromoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Desde \$99 MXN. Lo que vale el plan lo recibes en créditos de publicidad.'**
  String get plansLaunchPromoSubtitle;

  /// No description provided for @plansLaunchPromoValidUntil.
  ///
  /// In es, this message translates to:
  /// **'Válido hasta el 18 de julio de 2026'**
  String get plansLaunchPromoValidUntil;

  /// No description provided for @plansActivePlanFallback.
  ///
  /// In es, this message translates to:
  /// **'Plan activo'**
  String get plansActivePlanFallback;

  /// No description provided for @plansNoActivePlan.
  ///
  /// In es, this message translates to:
  /// **'Sin plan activo'**
  String get plansNoActivePlan;

  /// No description provided for @plansCurrentPlanLabel.
  ///
  /// In es, this message translates to:
  /// **'Tu plan actual'**
  String get plansCurrentPlanLabel;

  /// No description provided for @plansActiveBadge.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get plansActiveBadge;

  /// No description provided for @plansCurrentBadge.
  ///
  /// In es, this message translates to:
  /// **'Actual'**
  String get plansCurrentBadge;

  /// No description provided for @plansPricePerMonth.
  ///
  /// In es, this message translates to:
  /// **'\${amount} MXN/mes'**
  String plansPricePerMonth(Object amount);

  /// No description provided for @plansFree.
  ///
  /// In es, this message translates to:
  /// **'Gratis'**
  String get plansFree;

  /// No description provided for @plansMxnPerMonthSuffix.
  ///
  /// In es, this message translates to:
  /// **' MXN/mes'**
  String get plansMxnPerMonthSuffix;

  /// No description provided for @plansAdCredit.
  ///
  /// In es, this message translates to:
  /// **'+\${amount} en publicidad'**
  String plansAdCredit(Object amount);

  /// No description provided for @plansFeatureEstablishments.
  ///
  /// In es, this message translates to:
  /// **'{count} establecimiento(s)'**
  String plansFeatureEstablishments(Object count);

  /// No description provided for @plansFeaturePromotions.
  ///
  /// In es, this message translates to:
  /// **'{count} promociones normales activas'**
  String plansFeaturePromotions(Object count);

  /// No description provided for @plansFeatureFlashSingle.
  ///
  /// In es, this message translates to:
  /// **'1 promo flash al mes'**
  String get plansFeatureFlashSingle;

  /// No description provided for @plansFeatureFlashMulti.
  ///
  /// In es, this message translates to:
  /// **'1 promo flash/mes por establecimiento'**
  String get plansFeatureFlashMulti;

  /// No description provided for @plansFeatureBirthdaySingle.
  ///
  /// In es, this message translates to:
  /// **'Promo cumpleañero'**
  String get plansFeatureBirthdaySingle;

  /// No description provided for @plansFeatureBirthdayMulti.
  ///
  /// In es, this message translates to:
  /// **'Promo cumpleañero por establecimiento'**
  String get plansFeatureBirthdayMulti;

  /// No description provided for @plansFeatureLoyaltySingle.
  ///
  /// In es, this message translates to:
  /// **'Programa de fidelización'**
  String get plansFeatureLoyaltySingle;

  /// No description provided for @plansFeatureLoyaltyMulti.
  ///
  /// In es, this message translates to:
  /// **'Programa de fidelización por establecimiento'**
  String get plansFeatureLoyaltyMulti;

  /// No description provided for @plansFeatureStats.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas en tiempo real'**
  String get plansFeatureStats;

  /// No description provided for @plansFeaturePush.
  ///
  /// In es, this message translates to:
  /// **'{count} notificaciones push/mes'**
  String plansFeaturePush(Object count);

  /// No description provided for @plansActivePlanButton.
  ///
  /// In es, this message translates to:
  /// **'Plan activo'**
  String get plansActivePlanButton;

  /// No description provided for @plansProcessing.
  ///
  /// In es, this message translates to:
  /// **'Procesando...'**
  String get plansProcessing;

  /// No description provided for @plansSubscribe.
  ///
  /// In es, this message translates to:
  /// **'Suscribirme'**
  String get plansSubscribe;

  /// No description provided for @plansAddonsLabel.
  ///
  /// In es, this message translates to:
  /// **'ADD-ONS'**
  String get plansAddonsLabel;

  /// No description provided for @plansAddonsDescription.
  ///
  /// In es, this message translates to:
  /// **'Amplía tu plan con complementos mensuales. Se cobran cada mes y los cancelas cuando quieras.'**
  String get plansAddonsDescription;

  /// No description provided for @plansAddonEstablishmentTitle.
  ///
  /// In es, this message translates to:
  /// **'1 establecimiento adicional'**
  String get plansAddonEstablishmentTitle;

  /// No description provided for @plansAddonEstablishmentDesc.
  ///
  /// In es, this message translates to:
  /// **'Un local extra en tu cuenta. Se cobra cada mes hasta que lo canceles.'**
  String get plansAddonEstablishmentDesc;

  /// No description provided for @plansAddonEstablishmentPrice.
  ///
  /// In es, this message translates to:
  /// **'\$199 MXN/mes'**
  String get plansAddonEstablishmentPrice;

  /// No description provided for @plansAddonPromotionTitle.
  ///
  /// In es, this message translates to:
  /// **'1 promoción adicional'**
  String get plansAddonPromotionTitle;

  /// No description provided for @plansAddonPromotionDesc.
  ///
  /// In es, this message translates to:
  /// **'Una promoción extra en cualquier local. Se cobra cada mes hasta que la canceles.'**
  String get plansAddonPromotionDesc;

  /// No description provided for @plansAddonPromotionPrice.
  ///
  /// In es, this message translates to:
  /// **'\$49 MXN/mes'**
  String get plansAddonPromotionPrice;

  /// No description provided for @plansBuy.
  ///
  /// In es, this message translates to:
  /// **'Comprar'**
  String get plansBuy;

  /// No description provided for @plansActiveAddonsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis complementos activos'**
  String get plansActiveAddonsTitle;

  /// No description provided for @plansActiveAddonsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Se renuevan cada mes. Cancélalos cuando quieras.'**
  String get plansActiveAddonsSubtitle;

  /// No description provided for @plansAddonPromotionLabel.
  ///
  /// In es, this message translates to:
  /// **'Promoción adicional'**
  String get plansAddonPromotionLabel;

  /// No description provided for @plansAddonEstablishmentLabel.
  ///
  /// In es, this message translates to:
  /// **'Establecimiento adicional'**
  String get plansAddonEstablishmentLabel;

  /// No description provided for @plansCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get plansCancel;

  /// No description provided for @plansCancelAddonTitle.
  ///
  /// In es, this message translates to:
  /// **'Cancelar complemento'**
  String get plansCancelAddonTitle;

  /// No description provided for @plansCancelAddonConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Cancelar \"{label}\"? Dejará de cobrarse el próximo mes.'**
  String plansCancelAddonConfirm(Object label);

  /// No description provided for @plansCancelAddonConfirmWithPromos.
  ///
  /// In es, this message translates to:
  /// **'Se desactivarán {count} promoción(es) y se cancelará \"{label}\". ¿Continuar?'**
  String plansCancelAddonConfirmWithPromos(Object count, Object label);

  /// No description provided for @plansNo.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get plansNo;

  /// No description provided for @plansYesCancel.
  ///
  /// In es, this message translates to:
  /// **'Sí, cancelar'**
  String get plansYesCancel;

  /// No description provided for @plansAddonCancelled.
  ///
  /// In es, this message translates to:
  /// **'Complemento cancelado.'**
  String get plansAddonCancelled;

  /// No description provided for @plansCancelError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cancelar. Intenta de nuevo.'**
  String get plansCancelError;

  /// No description provided for @plansDeactivateDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Desactiva {count} promoción(es)'**
  String plansDeactivateDialogTitle(Object count);

  /// No description provided for @plansDeactivateDialogBody.
  ///
  /// In es, this message translates to:
  /// **'Al cancelar este complemento superas tu límite. Elige {count} para desactivar:'**
  String plansDeactivateDialogBody(Object count);

  /// No description provided for @plansPromoFallback.
  ///
  /// In es, this message translates to:
  /// **'Promo'**
  String get plansPromoFallback;

  /// No description provided for @plansContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get plansContinue;

  /// No description provided for @paymentSecureTitle.
  ///
  /// In es, this message translates to:
  /// **'Pago seguro'**
  String get paymentSecureTitle;

  /// No description provided for @paymentOpeningBrowser.
  ///
  /// In es, this message translates to:
  /// **'Abriendo MercadoPago en tu navegador...'**
  String get paymentOpeningBrowser;

  /// No description provided for @paymentCancelTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cancelar pago'**
  String get paymentCancelTooltip;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get profileTitle;

  /// No description provided for @profileSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get profileSignOut;

  /// No description provided for @profileNoName.
  ///
  /// In es, this message translates to:
  /// **'Sin nombre'**
  String get profileNoName;

  /// No description provided for @profileBusinessOwnerChip.
  ///
  /// In es, this message translates to:
  /// **'Dueño de negocio'**
  String get profileBusinessOwnerChip;

  /// No description provided for @profileLevelBusinessActive.
  ///
  /// In es, this message translates to:
  /// **'Negocio activo'**
  String get profileLevelBusinessActive;

  /// No description provided for @profileLevelStaff.
  ///
  /// In es, this message translates to:
  /// **'Empleado'**
  String get profileLevelStaff;

  /// No description provided for @profileAccountInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Información de la cuenta'**
  String get profileAccountInfoTitle;

  /// No description provided for @profileFieldName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get profileFieldName;

  /// No description provided for @profileFieldBirthDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get profileFieldBirthDate;

  /// No description provided for @profileFieldGender.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get profileFieldGender;

  /// No description provided for @profileGenderMale.
  ///
  /// In es, this message translates to:
  /// **'Hombre'**
  String get profileGenderMale;

  /// No description provided for @profileGenderFemale.
  ///
  /// In es, this message translates to:
  /// **'Mujer'**
  String get profileGenderFemale;

  /// No description provided for @profileGenderOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get profileGenderOther;

  /// No description provided for @profileBusinessMembershipTitle.
  ///
  /// In es, this message translates to:
  /// **'Membresía de negocio'**
  String get profileBusinessMembershipTitle;

  /// No description provided for @profileGoToMyBusiness.
  ///
  /// In es, this message translates to:
  /// **'Ir a Mi negocio'**
  String get profileGoToMyBusiness;

  /// No description provided for @profileViewPlansAndPayments.
  ///
  /// In es, this message translates to:
  /// **'Ver planes y pagos'**
  String get profileViewPlansAndPayments;

  /// No description provided for @profileBasicPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan básico'**
  String get profileBasicPlan;

  /// No description provided for @profileNoExpiry.
  ///
  /// In es, this message translates to:
  /// **'Sin vencimiento'**
  String get profileNoExpiry;

  /// No description provided for @profileExpired.
  ///
  /// In es, this message translates to:
  /// **'Vencido ({date})'**
  String profileExpired(Object date);

  /// No description provided for @profileExpiresOn.
  ///
  /// In es, this message translates to:
  /// **'Vence el {date}'**
  String profileExpiresOn(Object date);

  /// No description provided for @profileHaveBusinessTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Tienes un negocio?'**
  String get profileHaveBusinessTitle;

  /// No description provided for @profileHaveBusinessSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Regístralo y llega a más clientes'**
  String get profileHaveBusinessSubtitle;

  /// No description provided for @profileRegisterIt.
  ///
  /// In es, this message translates to:
  /// **'Regístralo'**
  String get profileRegisterIt;

  /// No description provided for @profileSheetTitleLoaded.
  ///
  /// In es, this message translates to:
  /// **'Ya está en Promofy'**
  String get profileSheetTitleLoaded;

  /// No description provided for @profileSheetTitleCode.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu código'**
  String get profileSheetTitleCode;

  /// No description provided for @profileSheetTitleNoCode.
  ///
  /// In es, this message translates to:
  /// **'Encuentra tu negocio'**
  String get profileSheetTitleNoCode;

  /// No description provided for @profileSheetTitleInitial.
  ///
  /// In es, this message translates to:
  /// **'Registra tu negocio'**
  String get profileSheetTitleInitial;

  /// No description provided for @profileOptionNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Es nuevo'**
  String get profileOptionNewTitle;

  /// No description provided for @profileOptionNewSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Quiero registrar mi negocio en Promofy'**
  String get profileOptionNewSubtitle;

  /// No description provided for @profileOptionLoadedTitle.
  ///
  /// In es, this message translates to:
  /// **'Ya está cargado'**
  String get profileOptionLoadedTitle;

  /// No description provided for @profileOptionLoadedSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Mi negocio ya existe en Promofy'**
  String get profileOptionLoadedSubtitle;

  /// No description provided for @profileOptionHaveCodeTitle.
  ///
  /// In es, this message translates to:
  /// **'Tengo código'**
  String get profileOptionHaveCodeTitle;

  /// No description provided for @profileOptionHaveCodeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresar mi código de invitación'**
  String get profileOptionHaveCodeSubtitle;

  /// No description provided for @profileOptionNoCodeTitle.
  ///
  /// In es, this message translates to:
  /// **'No tengo código'**
  String get profileOptionNoCodeTitle;

  /// No description provided for @profileOptionNoCodeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Buscar mi negocio por nombre y dirección'**
  String get profileOptionNoCodeSubtitle;

  /// No description provided for @profileEnterInvitationCode.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu código de invitación.'**
  String get profileEnterInvitationCode;

  /// No description provided for @profileInvalidCode.
  ///
  /// In es, this message translates to:
  /// **'Código inválido.'**
  String get profileInvalidCode;

  /// No description provided for @profileConnectionError.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión.'**
  String get profileConnectionError;

  /// No description provided for @profileInvitationCodeHint.
  ///
  /// In es, this message translates to:
  /// **'CÓDIGO DE INVITACIÓN'**
  String get profileInvitationCodeHint;

  /// No description provided for @profileVerifyCode.
  ///
  /// In es, this message translates to:
  /// **'Verificar código'**
  String get profileVerifyCode;

  /// No description provided for @profileValidCode.
  ///
  /// In es, this message translates to:
  /// **'¡Código válido!'**
  String get profileValidCode;

  /// No description provided for @profileEstablishmentFound.
  ///
  /// In es, this message translates to:
  /// **'Establecimiento encontrado'**
  String get profileEstablishmentFound;

  /// No description provided for @profileChooseMyPlan.
  ///
  /// In es, this message translates to:
  /// **'Elegir mi plan'**
  String get profileChooseMyPlan;

  /// No description provided for @profileBusinessNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre de tu negocio'**
  String get profileBusinessNameHint;

  /// No description provided for @profileAddressHint.
  ///
  /// In es, this message translates to:
  /// **'Dirección (calle, número, colonia…)'**
  String get profileAddressHint;

  /// No description provided for @profileEnterBusinessName.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el nombre de tu negocio.'**
  String get profileEnterBusinessName;

  /// No description provided for @profileSearchError.
  ///
  /// In es, this message translates to:
  /// **'Error al buscar. Intenta de nuevo.'**
  String get profileSearchError;

  /// No description provided for @profileSearchMyBusiness.
  ///
  /// In es, this message translates to:
  /// **'Buscar mi negocio'**
  String get profileSearchMyBusiness;

  /// No description provided for @profileNoMatches.
  ///
  /// In es, this message translates to:
  /// **'No encontramos coincidencias.\nRevisa el nombre o la dirección.'**
  String get profileNoMatches;

  /// No description provided for @profileSelectYourBusiness.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tu negocio:'**
  String get profileSelectYourBusiness;

  /// No description provided for @profileYourBusiness.
  ///
  /// In es, this message translates to:
  /// **'Tu negocio'**
  String get profileYourBusiness;

  /// No description provided for @profileAddressMatchQuestion.
  ///
  /// In es, this message translates to:
  /// **'Verificamos que la dirección coincide. ¿Es tu negocio?'**
  String get profileAddressMatchQuestion;

  /// No description provided for @profileYesItsMineChoosePlan.
  ///
  /// In es, this message translates to:
  /// **'Sí, es mío — Elegir plan'**
  String get profileYesItsMineChoosePlan;

  /// No description provided for @profileNotThisBusiness.
  ///
  /// In es, this message translates to:
  /// **'No es este negocio'**
  String get profileNotThisBusiness;

  /// No description provided for @profileBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get profileBack;

  /// No description provided for @profileFavoritesTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis favoritos'**
  String get profileFavoritesTitle;

  /// No description provided for @profileFavoritesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Promos y negocios que guardaste'**
  String get profileFavoritesSubtitle;

  /// No description provided for @profileSettingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get profileSettingsTitle;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Nombre, radio, gustos, contraseña y cuenta'**
  String get profileSettingsSubtitle;

  /// No description provided for @profileWorkplacesTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis lugares de trabajo'**
  String get profileWorkplacesTitle;

  /// No description provided for @profileNoWorkplaces.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron establecimientos asociados.'**
  String get profileNoWorkplaces;

  /// No description provided for @profileRoleManager.
  ///
  /// In es, this message translates to:
  /// **'Gerente'**
  String get profileRoleManager;

  /// No description provided for @profileRoleCashierWaiter.
  ///
  /// In es, this message translates to:
  /// **'Cajero / Mesero'**
  String get profileRoleCashierWaiter;

  /// No description provided for @profileRoleCashier.
  ///
  /// In es, this message translates to:
  /// **'Cajero'**
  String get profileRoleCashier;

  /// No description provided for @profileRoleCustom.
  ///
  /// In es, this message translates to:
  /// **'Personalizado'**
  String get profileRoleCustom;

  /// No description provided for @profileRoleLabel.
  ///
  /// In es, this message translates to:
  /// **'Rol: {role}'**
  String profileRoleLabel(Object role);

  /// No description provided for @profilePermLoyaltyQr.
  ///
  /// In es, this message translates to:
  /// **'QR lealtad'**
  String get profilePermLoyaltyQr;

  /// No description provided for @profilePermStats.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get profilePermStats;

  /// No description provided for @profilePermPromos.
  ///
  /// In es, this message translates to:
  /// **'Promos'**
  String get profilePermPromos;

  /// No description provided for @profileWorkAtBusinessTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Trabajas en un negocio?'**
  String get profileWorkAtBusinessTitle;

  /// No description provided for @profileWorkAtBusinessSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu código de invitación'**
  String get profileWorkAtBusinessSubtitle;

  /// No description provided for @profileJoin.
  ///
  /// In es, this message translates to:
  /// **'Unirse'**
  String get profileJoin;

  /// No description provided for @profileLinkCopied.
  ///
  /// In es, this message translates to:
  /// **'¡Link copiado al portapapeles!'**
  String get profileLinkCopied;

  /// No description provided for @profileReferralShareText.
  ///
  /// In es, this message translates to:
  /// **'¡Únete a Promofy y atrae más clientes a tu negocio!\nCrea tu cuenta con mi link y ambos ganamos:\n{url}'**
  String profileReferralShareText(Object url);

  /// No description provided for @profileReferralShareSubject.
  ///
  /// In es, this message translates to:
  /// **'Únete a Promofy'**
  String get profileReferralShareSubject;

  /// No description provided for @profileReferralTitle.
  ///
  /// In es, this message translates to:
  /// **'Programa de referidos'**
  String get profileReferralTitle;

  /// No description provided for @profileReferralDescription.
  ///
  /// In es, this message translates to:
  /// **'Invita a otros negocios con tu link. Cuando activen una membresía de pago, recibes \$300 MXN en créditos de publicidad.'**
  String get profileReferralDescription;

  /// No description provided for @profileCreditsEarned.
  ///
  /// In es, this message translates to:
  /// **'Créditos ganados'**
  String get profileCreditsEarned;

  /// No description provided for @profileCopied.
  ///
  /// In es, this message translates to:
  /// **'Copiado'**
  String get profileCopied;

  /// No description provided for @profileCopyLink.
  ///
  /// In es, this message translates to:
  /// **'Copiar link'**
  String get profileCopyLink;

  /// No description provided for @profileShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get profileShare;

  /// No description provided for @profileReferralLinkSoon.
  ///
  /// In es, this message translates to:
  /// **'Tu link de referido estará disponible en breve.'**
  String get profileReferralLinkSoon;

  /// No description provided for @profileAchievementsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Logros'**
  String get profileAchievementsTitle;

  /// No description provided for @profileSeeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todos'**
  String get profileSeeAll;

  /// No description provided for @profileVisitsToNextBadge.
  ///
  /// In es, this message translates to:
  /// **'{visits} visitas · faltan {toGo} para {nextBadge}'**
  String profileVisitsToNextBadge(Object visits, Object toGo, Object nextBadge);

  /// No description provided for @profileVisitsMaxLevel.
  ///
  /// In es, this message translates to:
  /// **'{visits} visitas este año — ¡nivel máximo!'**
  String profileVisitsMaxLevel(Object visits);

  /// No description provided for @profileStreakWeeks.
  ///
  /// In es, this message translates to:
  /// **'{weeks} sem. en racha'**
  String profileStreakWeeks(Object weeks);

  /// No description provided for @profileTopInCity.
  ///
  /// In es, this message translates to:
  /// **'Top {percent}% en tu ciudad'**
  String profileTopInCity(Object percent);

  /// No description provided for @profileWelcomeToTeam.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido al equipo!'**
  String get profileWelcomeToTeam;

  /// No description provided for @profileJoinATeam.
  ///
  /// In es, this message translates to:
  /// **'Unirse a un equipo'**
  String get profileJoinATeam;

  /// No description provided for @profileContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get profileContinue;

  /// No description provided for @profileCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get profileCancel;

  /// No description provided for @profileJoinMe.
  ///
  /// In es, this message translates to:
  /// **'Unirme'**
  String get profileJoinMe;

  /// No description provided for @profileCodeSixChars.
  ///
  /// In es, this message translates to:
  /// **'El código debe tener 6 caracteres.'**
  String get profileCodeSixChars;

  /// No description provided for @profileCodeInvalidOrExpired.
  ///
  /// In es, this message translates to:
  /// **'Código inválido o expirado.'**
  String get profileCodeInvalidOrExpired;

  /// No description provided for @profileConnectionErrorRetry.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión. Intenta de nuevo.'**
  String get profileConnectionErrorRetry;

  /// No description provided for @profileEnterSixCharCode.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código de 6 caracteres que te compartió el administrador.'**
  String get profileEnterSixCharCode;

  /// No description provided for @profileWillUpdateOnContinue.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil se actualizará al continuar.'**
  String get profileWillUpdateOnContinue;

  /// No description provided for @settingsName.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get settingsName;

  /// No description provided for @settingsNameHint.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre completo'**
  String get settingsNameHint;

  /// No description provided for @settingsNameEmpty.
  ///
  /// In es, this message translates to:
  /// **'El nombre no puede estar vacío.'**
  String get settingsNameEmpty;

  /// No description provided for @settingsSearchRadius.
  ///
  /// In es, this message translates to:
  /// **'Radio de búsqueda'**
  String get settingsSearchRadius;

  /// No description provided for @settingsPreferredTypes.
  ///
  /// In es, this message translates to:
  /// **'Tipos de lugar preferidos'**
  String get settingsPreferredTypes;

  /// No description provided for @settingsFavoriteFood.
  ///
  /// In es, this message translates to:
  /// **'Comida favorita'**
  String get settingsFavoriteFood;

  /// No description provided for @settingsLoadingCategories.
  ///
  /// In es, this message translates to:
  /// **'Cargando categorías…'**
  String get settingsLoadingCategories;

  /// No description provided for @settingsSaveButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar configuración'**
  String get settingsSaveButton;

  /// No description provided for @settingsSaved.
  ///
  /// In es, this message translates to:
  /// **'Configuración guardada.'**
  String get settingsSaved;

  /// No description provided for @settingsSaveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar. Intenta de nuevo.'**
  String get settingsSaveError;

  /// No description provided for @settingsAccountSecurity.
  ///
  /// In es, this message translates to:
  /// **'Cuenta y seguridad'**
  String get settingsAccountSecurity;

  /// No description provided for @settingsChangePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get settingsChangePassword;

  /// No description provided for @settingsNewPassword.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get settingsNewPassword;

  /// No description provided for @settingsConfirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get settingsConfirmPassword;

  /// No description provided for @settingsPasswordMin.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get settingsPasswordMin;

  /// No description provided for @settingsPasswordMismatch.
  ///
  /// In es, this message translates to:
  /// **'No coinciden'**
  String get settingsPasswordMismatch;

  /// No description provided for @settingsPasswordUpdated.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada.'**
  String get settingsPasswordUpdated;

  /// No description provided for @settingsPasswordError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar la contraseña. Intenta de nuevo.'**
  String get settingsPasswordError;

  /// No description provided for @settingsCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get settingsCancel;

  /// No description provided for @settingsSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get settingsSave;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro?'**
  String get settingsDeleteConfirmTitle;

  /// No description provided for @settingsDeleteConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Perderás toda tu información: tu perfil, favoritos, sellos de lealtad, historial y, si tienes un negocio, sus datos asociados.\n\nEsta acción es permanente y no se puede deshacer.'**
  String get settingsDeleteConfirmBody;

  /// No description provided for @settingsDeleteError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar la cuenta. Escríbenos a {email}'**
  String settingsDeleteError(Object email);

  /// No description provided for @bizMyBusiness.
  ///
  /// In es, this message translates to:
  /// **'Mi negocio'**
  String get bizMyBusiness;

  /// No description provided for @bizEditInfo.
  ///
  /// In es, this message translates to:
  /// **'Editar información'**
  String get bizEditInfo;

  /// No description provided for @bizPromoLimitReached.
  ///
  /// In es, this message translates to:
  /// **'Llegaste a tu límite de {max} promociones. Compra espacio extra o sube de plan para agregar más.'**
  String bizPromoLimitReached(Object max);

  /// No description provided for @bizEstablishmentLimitReached.
  ///
  /// In es, this message translates to:
  /// **'Tu plan \"{plan}\" permite hasta {max} establecimientos. Actualiza tu plan para agregar más.'**
  String bizEstablishmentLimitReached(Object plan, Object max);

  /// No description provided for @bizStatsTitle.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas de tu negocio'**
  String get bizStatsTitle;

  /// No description provided for @bizStatsGateDesc.
  ///
  /// In es, this message translates to:
  /// **'Activa un plan para ver impresiones, favoritos y demografía de tu audiencia.'**
  String get bizStatsGateDesc;

  /// No description provided for @bizViewPlans.
  ///
  /// In es, this message translates to:
  /// **'Ver planes'**
  String get bizViewPlans;

  /// No description provided for @bizUsageBusinesses.
  ///
  /// In es, this message translates to:
  /// **'neg.'**
  String get bizUsageBusinesses;

  /// No description provided for @bizUsagePromos.
  ///
  /// In es, this message translates to:
  /// **'promos'**
  String get bizUsagePromos;

  /// No description provided for @bizUpgrade.
  ///
  /// In es, this message translates to:
  /// **'Upgrade ↗'**
  String get bizUpgrade;

  /// No description provided for @bizAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get bizAdd;

  /// No description provided for @bizBusinessInfo.
  ///
  /// In es, this message translates to:
  /// **'Información del negocio'**
  String get bizBusinessInfo;

  /// No description provided for @bizNoExtraInfo.
  ///
  /// In es, this message translates to:
  /// **'Sin información adicional.'**
  String get bizNoExtraInfo;

  /// No description provided for @bizTypeLocal.
  ///
  /// In es, this message translates to:
  /// **'Local'**
  String get bizTypeLocal;

  /// No description provided for @bizTypeUrbanMobile.
  ///
  /// In es, this message translates to:
  /// **'Urbano / Móvil'**
  String get bizTypeUrbanMobile;

  /// No description provided for @bizPaymentCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta crédito/débito'**
  String get bizPaymentCard;

  /// No description provided for @bizPaymentCash.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get bizPaymentCash;

  /// No description provided for @bizPaymentOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get bizPaymentOther;

  /// No description provided for @bizAdultPromotions.
  ///
  /// In es, this message translates to:
  /// **'Tiene promociones para adultos'**
  String get bizAdultPromotions;

  /// No description provided for @bizDayMonday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get bizDayMonday;

  /// No description provided for @bizDayTuesday.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get bizDayTuesday;

  /// No description provided for @bizDayWednesday.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get bizDayWednesday;

  /// No description provided for @bizDayThursday.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get bizDayThursday;

  /// No description provided for @bizDayFriday.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get bizDayFriday;

  /// No description provided for @bizDaySaturday.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get bizDaySaturday;

  /// No description provided for @bizDaySunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get bizDaySunday;

  /// No description provided for @bizScheduleTitle.
  ///
  /// In es, this message translates to:
  /// **'Horario de atención'**
  String get bizScheduleTitle;

  /// No description provided for @bizClosed.
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get bizClosed;

  /// No description provided for @bizMyPromos.
  ///
  /// In es, this message translates to:
  /// **'Mis promociones'**
  String get bizMyPromos;

  /// No description provided for @bizFeaturedHint.
  ///
  /// In es, this message translates to:
  /// **'Activa \"Destacada\" para que tu promo aparezca primero en la búsqueda.'**
  String get bizFeaturedHint;

  /// No description provided for @bizNoPromosYet.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes promociones en este negocio.'**
  String get bizNoPromosYet;

  /// No description provided for @bizPlanLimitTitle.
  ///
  /// In es, this message translates to:
  /// **'Llegaste al límite de tu plan'**
  String get bizPlanLimitTitle;

  /// No description provided for @bizBuyExtraSpaceDesc.
  ///
  /// In es, this message translates to:
  /// **'Compra espacio extra y sigue publicando sin cambiar de plan.'**
  String get bizBuyExtraSpaceDesc;

  /// No description provided for @bizBuyPromoSpace.
  ///
  /// In es, this message translates to:
  /// **'Comprar espacio de promoción'**
  String get bizBuyPromoSpace;

  /// No description provided for @bizEditAvailableOn.
  ///
  /// In es, this message translates to:
  /// **'Edición disponible el {date}'**
  String bizEditAvailableOn(Object date);

  /// No description provided for @bizPromoNotEditableYet.
  ///
  /// In es, this message translates to:
  /// **'Esta promoción aún no puede editarse.'**
  String get bizPromoNotEditableYet;

  /// No description provided for @bizEditableOn.
  ///
  /// In es, this message translates to:
  /// **'Editable el {date}'**
  String bizEditableOn(Object date);

  /// No description provided for @bizLocked.
  ///
  /// In es, this message translates to:
  /// **'Bloqueada'**
  String get bizLocked;

  /// No description provided for @bizFeatured.
  ///
  /// In es, this message translates to:
  /// **'Destacada'**
  String get bizFeatured;

  /// No description provided for @bizFlash.
  ///
  /// In es, this message translates to:
  /// **'Flash'**
  String get bizFlash;

  /// No description provided for @bizMyTeam.
  ///
  /// In es, this message translates to:
  /// **'Mi equipo'**
  String get bizMyTeam;

  /// No description provided for @bizInvite.
  ///
  /// In es, this message translates to:
  /// **'Invitar'**
  String get bizInvite;

  /// No description provided for @bizRemoveFromTeamTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar del equipo'**
  String get bizRemoveFromTeamTitle;

  /// No description provided for @bizRemoveFromTeamConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Quitar a {name} del equipo?'**
  String bizRemoveFromTeamConfirm(Object name);

  /// No description provided for @bizCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get bizCancel;

  /// No description provided for @bizRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get bizRemove;

  /// No description provided for @bizRemoveTeamError.
  ///
  /// In es, this message translates to:
  /// **'Error al quitar del equipo: {error}'**
  String bizRemoveTeamError(Object error);

  /// No description provided for @bizNoStaffYet.
  ///
  /// In es, this message translates to:
  /// **'Sin empleados aún.\nToca \"Invitar\" para generar un código.'**
  String get bizNoStaffYet;

  /// No description provided for @bizRemoveFromTeamTooltip.
  ///
  /// In es, this message translates to:
  /// **'Quitar del equipo'**
  String get bizRemoveFromTeamTooltip;

  /// No description provided for @bizGenerateCodeError.
  ///
  /// In es, this message translates to:
  /// **'Error al generar código: {error}'**
  String bizGenerateCodeError(Object error);

  /// No description provided for @bizInviteStaff.
  ///
  /// In es, this message translates to:
  /// **'Invitar empleado'**
  String get bizInviteStaff;

  /// No description provided for @bizCodeAvailable48h.
  ///
  /// In es, this message translates to:
  /// **'El código estará disponible por 48 horas.'**
  String get bizCodeAvailable48h;

  /// No description provided for @bizRoleLabel.
  ///
  /// In es, this message translates to:
  /// **'ROL'**
  String get bizRoleLabel;

  /// No description provided for @bizRoleCashier.
  ///
  /// In es, this message translates to:
  /// **'Cajero / Mesero'**
  String get bizRoleCashier;

  /// No description provided for @bizRoleCashierDesc.
  ///
  /// In es, this message translates to:
  /// **'Solo puede escanear el QR de lealtad'**
  String get bizRoleCashierDesc;

  /// No description provided for @bizRoleManager.
  ///
  /// In es, this message translates to:
  /// **'Gerente'**
  String get bizRoleManager;

  /// No description provided for @bizRoleManagerDesc.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas, promos y QR de lealtad'**
  String get bizRoleManagerDesc;

  /// No description provided for @bizRoleCustom.
  ///
  /// In es, this message translates to:
  /// **'Personalizado'**
  String get bizRoleCustom;

  /// No description provided for @bizRoleCustomDesc.
  ///
  /// In es, this message translates to:
  /// **'Elige los permisos manualmente'**
  String get bizRoleCustomDesc;

  /// No description provided for @bizPermissionsLabel.
  ///
  /// In es, this message translates to:
  /// **'PERMISOS'**
  String get bizPermissionsLabel;

  /// No description provided for @bizPermScanQr.
  ///
  /// In es, this message translates to:
  /// **'Escanear QR de lealtad'**
  String get bizPermScanQr;

  /// No description provided for @bizPermViewStats.
  ///
  /// In es, this message translates to:
  /// **'Ver estadísticas'**
  String get bizPermViewStats;

  /// No description provided for @bizPermManagePromos.
  ///
  /// In es, this message translates to:
  /// **'Gestionar promociones'**
  String get bizPermManagePromos;

  /// No description provided for @bizPermManagePayments.
  ///
  /// In es, this message translates to:
  /// **'Gestionar pagos'**
  String get bizPermManagePayments;

  /// No description provided for @bizGenerating.
  ///
  /// In es, this message translates to:
  /// **'Generando…'**
  String get bizGenerating;

  /// No description provided for @bizGenerateCode.
  ///
  /// In es, this message translates to:
  /// **'Generar código'**
  String get bizGenerateCode;

  /// No description provided for @bizCodeGenerated.
  ///
  /// In es, this message translates to:
  /// **'Código generado'**
  String get bizCodeGenerated;

  /// No description provided for @bizCodeRole.
  ///
  /// In es, this message translates to:
  /// **'Rol: {role}'**
  String bizCodeRole(Object role);

  /// No description provided for @bizCodeValid48h.
  ///
  /// In es, this message translates to:
  /// **'Válido por 48 horas.\nCompartir con el empleado para que lo ingrese en la app.'**
  String get bizCodeValid48h;

  /// No description provided for @bizCodeCopied.
  ///
  /// In es, this message translates to:
  /// **'Código copiado'**
  String get bizCodeCopied;

  /// No description provided for @bizCopyCode.
  ///
  /// In es, this message translates to:
  /// **'Copiar código'**
  String get bizCopyCode;

  /// No description provided for @bizDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get bizDone;

  /// No description provided for @bizPushNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones push'**
  String get bizPushNotifications;

  /// No description provided for @bizNoNotifications.
  ///
  /// In es, this message translates to:
  /// **'Sin notificaciones en este período.\nSe generan automáticamente al crear una promo flash.'**
  String get bizNoNotifications;

  /// No description provided for @bizKpiSent.
  ///
  /// In es, this message translates to:
  /// **'Envíos'**
  String get bizKpiSent;

  /// No description provided for @bizKpiReached.
  ///
  /// In es, this message translates to:
  /// **'Alcanzados'**
  String get bizKpiReached;

  /// No description provided for @bizKpiOpenRate.
  ///
  /// In es, this message translates to:
  /// **'Tasa apertura'**
  String get bizKpiOpenRate;

  /// No description provided for @bizRecentHistory.
  ///
  /// In es, this message translates to:
  /// **'HISTORIAL RECIENTE'**
  String get bizRecentHistory;

  /// No description provided for @bizNotifSentLine.
  ///
  /// In es, this message translates to:
  /// **'{date} · {count} enviadas'**
  String bizNotifSentLine(Object date, Object count);

  /// No description provided for @bizOpenRateShort.
  ///
  /// In es, this message translates to:
  /// **'{pct}% apert.'**
  String bizOpenRateShort(Object pct);

  /// No description provided for @bizBoostBusiness.
  ///
  /// In es, this message translates to:
  /// **'Impulsa tu negocio'**
  String get bizBoostBusiness;

  /// No description provided for @bizPlanIncludes.
  ///
  /// In es, this message translates to:
  /// **'Tu plan \"{plan}\" incluye hasta {establishments} negocios y {promotions} promociones normales.'**
  String bizPlanIncludes(Object plan, Object establishments, Object promotions);

  /// No description provided for @bizEmptyTagline.
  ///
  /// In es, this message translates to:
  /// **'Publica promociones y llega a miles de clientes en tu ciudad.'**
  String get bizEmptyTagline;

  /// No description provided for @bizRegisterMyBusiness.
  ///
  /// In es, this message translates to:
  /// **'Registrar mi negocio'**
  String get bizRegisterMyBusiness;

  /// No description provided for @bizAdvertising.
  ///
  /// In es, this message translates to:
  /// **'Publicidad'**
  String get bizAdvertising;

  /// No description provided for @bizNewCampaign.
  ///
  /// In es, this message translates to:
  /// **'Nueva campaña'**
  String get bizNewCampaign;

  /// No description provided for @bizAvailableCredit.
  ///
  /// In es, this message translates to:
  /// **'Crédito disponible'**
  String get bizAvailableCredit;

  /// No description provided for @bizReachableBanner.
  ///
  /// In es, this message translates to:
  /// **'≈ {count} personas alcanzables (banner)'**
  String bizReachableBanner(Object count);

  /// No description provided for @bizTopUp.
  ///
  /// In es, this message translates to:
  /// **'Recargar'**
  String get bizTopUp;

  /// No description provided for @bizNoActiveCampaigns.
  ///
  /// In es, this message translates to:
  /// **'Sin campañas activas'**
  String get bizNoActiveCampaigns;

  /// No description provided for @bizOngoingCampaigns.
  ///
  /// In es, this message translates to:
  /// **'Campañas en curso'**
  String get bizOngoingCampaigns;

  /// No description provided for @bizSpent.
  ///
  /// In es, this message translates to:
  /// **'Gastado: {amount}'**
  String bizSpent(Object amount);

  /// No description provided for @bizBudget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto: {amount}'**
  String bizBudget(Object amount);

  /// No description provided for @bizPause.
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get bizPause;

  /// No description provided for @bizResume.
  ///
  /// In es, this message translates to:
  /// **'Reanudar'**
  String get bizResume;

  /// No description provided for @bizTransactionHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de movimientos'**
  String get bizTransactionHistory;

  /// No description provided for @bizRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get bizRetry;

  /// No description provided for @bizGeoBoth.
  ///
  /// In es, this message translates to:
  /// **'Física + búsqueda'**
  String get bizGeoBoth;

  /// No description provided for @bizGeoPhysical.
  ///
  /// In es, this message translates to:
  /// **'Solo ubicación física'**
  String get bizGeoPhysical;

  /// No description provided for @bizGeoSearchArea.
  ///
  /// In es, this message translates to:
  /// **'Solo área de búsqueda'**
  String get bizGeoSearchArea;

  /// No description provided for @bizErrorNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get bizErrorNameRequired;

  /// No description provided for @bizErrorBudgetInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un presupuesto válido'**
  String get bizErrorBudgetInvalid;

  /// No description provided for @bizErrorMinBudget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto mínimo para este formato: {amount}'**
  String bizErrorMinBudget(Object amount);

  /// No description provided for @bizErrorInsufficientBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo insuficiente. Disponible: {amount}'**
  String bizErrorInsufficientBalance(Object amount);

  /// No description provided for @bizErrorSelectPromo.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la promoción que quieres publicitar'**
  String get bizErrorSelectPromo;

  /// No description provided for @bizCampaignName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la campaña'**
  String get bizCampaignName;

  /// No description provided for @bizWhatToAdvertise.
  ///
  /// In es, this message translates to:
  /// **'¿Qué publicitarás?'**
  String get bizWhatToAdvertise;

  /// No description provided for @bizYourBusiness.
  ///
  /// In es, this message translates to:
  /// **'Tu negocio'**
  String get bizYourBusiness;

  /// No description provided for @bizOnePromotion.
  ///
  /// In es, this message translates to:
  /// **'Una promoción'**
  String get bizOnePromotion;

  /// No description provided for @bizWhereToShow.
  ///
  /// In es, this message translates to:
  /// **'¿Dónde quieres mostrarlo?'**
  String get bizWhereToShow;

  /// No description provided for @bizPlacementSplash.
  ///
  /// In es, this message translates to:
  /// **'Splash al abrir la app'**
  String get bizPlacementSplash;

  /// No description provided for @bizPlacementFeed.
  ///
  /// In es, this message translates to:
  /// **'En el feed de promos'**
  String get bizPlacementFeed;

  /// No description provided for @bizPlacementBanner.
  ///
  /// In es, this message translates to:
  /// **'Banner en el inicio'**
  String get bizPlacementBanner;

  /// No description provided for @bizSpecialFormats.
  ///
  /// In es, this message translates to:
  /// **'Formatos especiales'**
  String get bizSpecialFormats;

  /// No description provided for @bizFormatPush.
  ///
  /// In es, this message translates to:
  /// **'Notif. push'**
  String get bizFormatPush;

  /// No description provided for @bizFormatFlash.
  ///
  /// In es, this message translates to:
  /// **'Promo Relámpago'**
  String get bizFormatFlash;

  /// No description provided for @bizBudgetMxn.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto (MXN)'**
  String get bizBudgetMxn;

  /// No description provided for @bizMinimum.
  ///
  /// In es, this message translates to:
  /// **'Mínimo {amount}'**
  String bizMinimum(Object amount);

  /// No description provided for @bizEstimatedReach.
  ///
  /// In es, this message translates to:
  /// **'Alcance estimado: {count} personas'**
  String bizEstimatedReach(Object count);

  /// No description provided for @bizRadius.
  ///
  /// In es, this message translates to:
  /// **'Radio:'**
  String get bizRadius;

  /// No description provided for @bizGeoSegmentation.
  ///
  /// In es, this message translates to:
  /// **'Segmentación geográfica'**
  String get bizGeoSegmentation;

  /// No description provided for @bizAge.
  ///
  /// In es, this message translates to:
  /// **'Edad:'**
  String get bizAge;

  /// No description provided for @bizAgeRange.
  ///
  /// In es, this message translates to:
  /// **'{min} – {max} años'**
  String bizAgeRange(Object min, Object max);

  /// No description provided for @bizYearsOld.
  ///
  /// In es, this message translates to:
  /// **'{age} años'**
  String bizYearsOld(Object age);

  /// No description provided for @bizGender.
  ///
  /// In es, this message translates to:
  /// **'Sexo'**
  String get bizGender;

  /// No description provided for @bizGenderAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get bizGenderAll;

  /// No description provided for @bizGenderMale.
  ///
  /// In es, this message translates to:
  /// **'Hombres'**
  String get bizGenderMale;

  /// No description provided for @bizGenderFemale.
  ///
  /// In es, this message translates to:
  /// **'Mujeres'**
  String get bizGenderFemale;

  /// No description provided for @bizAudienceWithFilters.
  ///
  /// In es, this message translates to:
  /// **'Audiencia con estos filtros: {count} personas'**
  String bizAudienceWithFilters(Object count);

  /// No description provided for @bizCalculatingAudience.
  ///
  /// In es, this message translates to:
  /// **'Calculando audiencia...'**
  String get bizCalculatingAudience;

  /// No description provided for @bizPromoToAdvertise.
  ///
  /// In es, this message translates to:
  /// **'Promoción a publicitar'**
  String get bizPromoToAdvertise;

  /// No description provided for @bizCreatePromoFirst.
  ///
  /// In es, this message translates to:
  /// **'Crea al menos una promoción activa antes de lanzar una campaña.'**
  String get bizCreatePromoFirst;

  /// No description provided for @bizLaunchCampaign.
  ///
  /// In es, this message translates to:
  /// **'Lanzar campaña'**
  String get bizLaunchCampaign;

  /// No description provided for @bizRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get bizRefresh;

  /// No description provided for @bizNoAssignedEstablishments.
  ///
  /// In es, this message translates to:
  /// **'Sin establecimientos asignados'**
  String get bizNoAssignedEstablishments;

  /// No description provided for @bizAskOwnerToInvite.
  ///
  /// In es, this message translates to:
  /// **'Pide al dueño del negocio que te invite con un código.'**
  String get bizAskOwnerToInvite;

  /// No description provided for @bizPermManagePromosShort.
  ///
  /// In es, this message translates to:
  /// **'Gestionar promos'**
  String get bizPermManagePromosShort;

  /// No description provided for @bizScanStamps.
  ///
  /// In es, this message translates to:
  /// **'Escanear sellos'**
  String get bizScanStamps;

  /// No description provided for @bizPromoTypeFlash.
  ///
  /// In es, this message translates to:
  /// **'Flash'**
  String get bizPromoTypeFlash;

  /// No description provided for @bizPromoTypeDaily.
  ///
  /// In es, this message translates to:
  /// **'Diaria'**
  String get bizPromoTypeDaily;

  /// No description provided for @bizPromoTypeWeekly.
  ///
  /// In es, this message translates to:
  /// **'Semanal'**
  String get bizPromoTypeWeekly;

  /// No description provided for @bizPromoTypePermanent.
  ///
  /// In es, this message translates to:
  /// **'Permanente'**
  String get bizPromoTypePermanent;

  /// No description provided for @bizActive.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get bizActive;

  /// No description provided for @bizInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactiva'**
  String get bizInactive;

  /// No description provided for @bizMinAmount50.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un monto mínimo de \$50 MXN'**
  String get bizMinAmount50;

  /// No description provided for @bizCannotOpenMercadoPago.
  ///
  /// In es, this message translates to:
  /// **'No se pudo abrir MercadoPago'**
  String get bizCannotOpenMercadoPago;

  /// No description provided for @bizRedirectedToMercadoPago.
  ///
  /// In es, this message translates to:
  /// **'Redirigido a MercadoPago. El saldo se actualizará en minutos tras el pago.'**
  String get bizRedirectedToMercadoPago;

  /// No description provided for @bizTopUpAdCredit.
  ///
  /// In es, this message translates to:
  /// **'Recargar crédito publicitario'**
  String get bizTopUpAdCredit;

  /// No description provided for @bizTopUpDesc.
  ///
  /// In es, this message translates to:
  /// **'Cada impresión deduce crédito según el formato de la campaña. El pago es procesado por MercadoPago.'**
  String get bizTopUpDesc;

  /// No description provided for @bizAmountToTopUp.
  ///
  /// In es, this message translates to:
  /// **'MONTO A RECARGAR'**
  String get bizAmountToTopUp;

  /// No description provided for @bizOtherAmount.
  ///
  /// In es, this message translates to:
  /// **'Otro monto'**
  String get bizOtherAmount;

  /// No description provided for @bizMin50Mxn.
  ///
  /// In es, this message translates to:
  /// **'Mínimo \$50 MXN'**
  String get bizMin50Mxn;

  /// No description provided for @bizTotalToPay.
  ///
  /// In es, this message translates to:
  /// **'Total a pagar: {amount} MXN'**
  String bizTotalToPay(Object amount);

  /// No description provided for @bizPreparingPayment.
  ///
  /// In es, this message translates to:
  /// **'Preparando pago…'**
  String get bizPreparingPayment;

  /// No description provided for @bizPayWithMercadoPago.
  ///
  /// In es, this message translates to:
  /// **'Pagar con MercadoPago'**
  String get bizPayWithMercadoPago;

  /// No description provided for @bizWillRedirectMercadoPago.
  ///
  /// In es, this message translates to:
  /// **'Serás redirigido al sitio de MercadoPago.'**
  String get bizWillRedirectMercadoPago;

  /// No description provided for @regBizCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar negocio'**
  String get regBizCreateTitle;

  /// No description provided for @regBizEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar negocio'**
  String get regBizEditTitle;

  /// No description provided for @regBizBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get regBizBack;

  /// No description provided for @regBizNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get regBizNext;

  /// No description provided for @regBizSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get regBizSaveChanges;

  /// No description provided for @regBizStepOf.
  ///
  /// In es, this message translates to:
  /// **'Paso {step} de {total}'**
  String regBizStepOf(Object step, Object total);

  /// No description provided for @regBizStepBasic.
  ///
  /// In es, this message translates to:
  /// **'Datos básicos'**
  String get regBizStepBasic;

  /// No description provided for @regBizStepType.
  ///
  /// In es, this message translates to:
  /// **'Tipo y categoría'**
  String get regBizStepType;

  /// No description provided for @regBizStepSchedule.
  ///
  /// In es, this message translates to:
  /// **'Horario y extras'**
  String get regBizStepSchedule;

  /// No description provided for @regBizUpdatedOk.
  ///
  /// In es, this message translates to:
  /// **'Negocio actualizado correctamente.'**
  String get regBizUpdatedOk;

  /// No description provided for @regBizCreatedOk.
  ///
  /// In es, this message translates to:
  /// **'¡Negocio registrado! Ya apareces en Promofy.'**
  String get regBizCreatedOk;

  /// No description provided for @regBizSelectAddressHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una dirección del buscador para obtener la ubicación.'**
  String get regBizSelectAddressHint;

  /// No description provided for @regBizSelectType.
  ///
  /// In es, this message translates to:
  /// **'Selecciona el tipo de establecimiento.'**
  String get regBizSelectType;

  /// No description provided for @regBizSelectCategory.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos una categoría.'**
  String get regBizSelectCategory;

  /// No description provided for @regBizSelectCharacteristic.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos una característica.'**
  String get regBizSelectCharacteristic;

  /// No description provided for @regBizSelectPayment.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos un método de pago.'**
  String get regBizSelectPayment;

  /// No description provided for @regBizSelectDay.
  ///
  /// In es, this message translates to:
  /// **'Agrega al menos un día de atención.'**
  String get regBizSelectDay;

  /// No description provided for @regBizSectionMain.
  ///
  /// In es, this message translates to:
  /// **'Información principal'**
  String get regBizSectionMain;

  /// No description provided for @regBizNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del negocio *'**
  String get regBizNameLabel;

  /// No description provided for @regBizNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Tacos El Gordo'**
  String get regBizNameHint;

  /// No description provided for @regBizNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get regBizNameRequired;

  /// No description provided for @regBizDescLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get regBizDescLabel;

  /// No description provided for @regBizDescHint.
  ///
  /// In es, this message translates to:
  /// **'Describe brevemente tu negocio…'**
  String get regBizDescHint;

  /// No description provided for @regBizSectionLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get regBizSectionLocation;

  /// No description provided for @regBizAddressLabel.
  ///
  /// In es, this message translates to:
  /// **'Dirección'**
  String get regBizAddressLabel;

  /// No description provided for @regBizAddressLabelRequired.
  ///
  /// In es, this message translates to:
  /// **'Dirección *'**
  String get regBizAddressLabelRequired;

  /// No description provided for @regBizAddressHint.
  ///
  /// In es, this message translates to:
  /// **'Toca para buscar la dirección…'**
  String get regBizAddressHint;

  /// No description provided for @regBizAddressHelper.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la dirección de las sugerencias para obtener coordenadas.'**
  String get regBizAddressHelper;

  /// No description provided for @regBizSectionContact.
  ///
  /// In es, this message translates to:
  /// **'Contacto'**
  String get regBizSectionContact;

  /// No description provided for @regBizPhoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Teléfono / WhatsApp'**
  String get regBizPhoneLabel;

  /// No description provided for @regBizPhoneHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. 4491234567'**
  String get regBizPhoneHint;

  /// No description provided for @regBizSectionSocial.
  ///
  /// In es, this message translates to:
  /// **'Redes sociales'**
  String get regBizSectionSocial;

  /// No description provided for @regBizWebsiteLabel.
  ///
  /// In es, this message translates to:
  /// **'Sitio web'**
  String get regBizWebsiteLabel;

  /// No description provided for @regBizTypeSection.
  ///
  /// In es, this message translates to:
  /// **'Tipo de establecimiento *'**
  String get regBizTypeSection;

  /// No description provided for @regBizTypeLocal.
  ///
  /// In es, this message translates to:
  /// **'Local'**
  String get regBizTypeLocal;

  /// No description provided for @regBizTypeLocalSub.
  ///
  /// In es, this message translates to:
  /// **'Dirección fija'**
  String get regBizTypeLocalSub;

  /// No description provided for @regBizTypeMobile.
  ///
  /// In es, this message translates to:
  /// **'Urbano / Móvil'**
  String get regBizTypeMobile;

  /// No description provided for @regBizTypeMobileSub.
  ///
  /// In es, this message translates to:
  /// **'Ubicación variable'**
  String get regBizTypeMobileSub;

  /// No description provided for @regBizCategorySection.
  ///
  /// In es, this message translates to:
  /// **'Categoría *'**
  String get regBizCategorySection;

  /// No description provided for @regBizCategoryHelper.
  ///
  /// In es, this message translates to:
  /// **'Puedes seleccionar una o varias. La subcategoría es opcional.'**
  String get regBizCategoryHelper;

  /// No description provided for @regBizSubcategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'↳ Subcategoría (opcional)'**
  String get regBizSubcategoryLabel;

  /// No description provided for @regBizSpecialtyLabel.
  ///
  /// In es, this message translates to:
  /// **'↳ Especialidad (opcional)'**
  String get regBizSpecialtyLabel;

  /// No description provided for @regBizExtraSection.
  ///
  /// In es, this message translates to:
  /// **'Información adicional'**
  String get regBizExtraSection;

  /// No description provided for @regBizAdultPromos.
  ///
  /// In es, this message translates to:
  /// **'¿Tiene promociones para mayores de edad?'**
  String get regBizAdultPromos;

  /// No description provided for @regBizScheduleSection.
  ///
  /// In es, this message translates to:
  /// **'Horario de atención *'**
  String get regBizScheduleSection;

  /// No description provided for @regBizScheduleHelper.
  ///
  /// In es, this message translates to:
  /// **'Activa los días que atiendes y ajusta los horarios.'**
  String get regBizScheduleHelper;

  /// No description provided for @regBizCharSection.
  ///
  /// In es, this message translates to:
  /// **'Características *'**
  String get regBizCharSection;

  /// No description provided for @regBizCharHelper.
  ///
  /// In es, this message translates to:
  /// **'Selecciona las que apliquen a tu negocio.'**
  String get regBizCharHelper;

  /// No description provided for @regBizPaymentSection.
  ///
  /// In es, this message translates to:
  /// **'Métodos de pago *'**
  String get regBizPaymentSection;

  /// No description provided for @regBizPaymentCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta crédito/débito'**
  String get regBizPaymentCard;

  /// No description provided for @regBizPaymentCash.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get regBizPaymentCash;

  /// No description provided for @regBizPaymentOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get regBizPaymentOther;

  /// No description provided for @regBizClosed.
  ///
  /// In es, this message translates to:
  /// **'Cerrado'**
  String get regBizClosed;

  /// No description provided for @regBizDayMonday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get regBizDayMonday;

  /// No description provided for @regBizDayTuesday.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get regBizDayTuesday;

  /// No description provided for @regBizDayWednesday.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get regBizDayWednesday;

  /// No description provided for @regBizDayThursday.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get regBizDayThursday;

  /// No description provided for @regBizDayFriday.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get regBizDayFriday;

  /// No description provided for @regBizDaySaturday.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get regBizDaySaturday;

  /// No description provided for @regBizDaySunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get regBizDaySunday;

  /// No description provided for @regBizSearchAddressTitle.
  ///
  /// In es, this message translates to:
  /// **'Buscar dirección'**
  String get regBizSearchAddressTitle;

  /// No description provided for @regBizSearchAddressHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe la dirección de tu negocio…'**
  String get regBizSearchAddressHint;

  /// No description provided for @regBizNoResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados. Intenta con otra búsqueda.'**
  String get regBizNoResults;

  /// No description provided for @regBizSearchError.
  ///
  /// In es, this message translates to:
  /// **'Error al buscar. Intenta de nuevo.'**
  String get regBizSearchError;

  /// No description provided for @regBizLocationError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener la ubicación.'**
  String get regBizLocationError;

  /// No description provided for @promoFormEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar promoción'**
  String get promoFormEditTitle;

  /// No description provided for @promoFormNewTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva promoción'**
  String get promoFormNewTitle;

  /// No description provided for @promoFormDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get promoFormDelete;

  /// No description provided for @promoFormCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get promoFormCancel;

  /// No description provided for @promoFormClear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get promoFormClear;

  /// No description provided for @promoFormSelectThis.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar esta'**
  String get promoFormSelectThis;

  /// No description provided for @promoFormCategorySheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Categoría de la promoción'**
  String get promoFormCategorySheetTitle;

  /// No description provided for @promoFormCategoryLevel1.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get promoFormCategoryLevel1;

  /// No description provided for @promoFormSubcategory.
  ///
  /// In es, this message translates to:
  /// **'Subcategoría'**
  String get promoFormSubcategory;

  /// No description provided for @promoFormSpecialty.
  ///
  /// In es, this message translates to:
  /// **'Especialidad'**
  String get promoFormSpecialty;

  /// No description provided for @promoFormOptionalTag.
  ///
  /// In es, this message translates to:
  /// **'opcional'**
  String get promoFormOptionalTag;

  /// No description provided for @promoFormStartDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de inicio'**
  String get promoFormStartDate;

  /// No description provided for @promoFormEndDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de fin'**
  String get promoFormEndDate;

  /// No description provided for @promoFormStartTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de inicio'**
  String get promoFormStartTime;

  /// No description provided for @promoFormEndTime.
  ///
  /// In es, this message translates to:
  /// **'Hora de fin'**
  String get promoFormEndTime;

  /// No description provided for @promoFormEndTimeSameDay.
  ///
  /// In es, this message translates to:
  /// **'Hora de fin (mismo día)'**
  String get promoFormEndTimeSameDay;

  /// No description provided for @promoFormErrorNameRequired.
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio.'**
  String get promoFormErrorNameRequired;

  /// No description provided for @promoFormErrorSelectDay.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos un día.'**
  String get promoFormErrorSelectDay;

  /// No description provided for @promoFormErrorStartDateTime.
  ///
  /// In es, this message translates to:
  /// **'Indica la fecha y hora de inicio.'**
  String get promoFormErrorStartDateTime;

  /// No description provided for @promoFormErrorEndTime.
  ///
  /// In es, this message translates to:
  /// **'Indica la hora de fin.'**
  String get promoFormErrorEndTime;

  /// No description provided for @promoFormErrorEndAfterStart.
  ///
  /// In es, this message translates to:
  /// **'La hora de fin debe ser posterior al inicio.'**
  String get promoFormErrorEndAfterStart;

  /// No description provided for @promoFormErrorSameDay.
  ///
  /// In es, this message translates to:
  /// **'La promo flash debe iniciar y terminar el mismo día.'**
  String get promoFormErrorSameDay;

  /// No description provided for @promoFormConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Todo está correcto?'**
  String get promoFormConfirmTitle;

  /// No description provided for @promoFormConfirmName.
  ///
  /// In es, this message translates to:
  /// **'\"{name}\"'**
  String promoFormConfirmName(Object name);

  /// No description provided for @promoFormConfirmIntro.
  ///
  /// In es, this message translates to:
  /// **'Una vez creada, '**
  String get promoFormConfirmIntro;

  /// No description provided for @promoFormConfirmLockWarning.
  ///
  /// In es, this message translates to:
  /// **'no podrás editar esta promoción durante 15 días.'**
  String get promoFormConfirmLockWarning;

  /// No description provided for @promoFormConfirmReview.
  ///
  /// In es, this message translates to:
  /// **'\n\nRevisa con detalle el nombre, descripción, horarios y días activos antes de continuar.'**
  String get promoFormConfirmReview;

  /// No description provided for @promoFormReviewMore.
  ///
  /// In es, this message translates to:
  /// **'Revisar más'**
  String get promoFormReviewMore;

  /// No description provided for @promoFormConfirmCreate.
  ///
  /// In es, this message translates to:
  /// **'Sí, crear promoción'**
  String get promoFormConfirmCreate;

  /// No description provided for @promoFormSaveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar: {error}'**
  String promoFormSaveError(Object error);

  /// No description provided for @promoFormDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar promoción'**
  String get promoFormDeleteTitle;

  /// No description provided for @promoFormDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar esta promoción? Esta acción no se puede deshacer.'**
  String get promoFormDeleteConfirm;

  /// No description provided for @promoFormDeleteError.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar: {error}'**
  String promoFormDeleteError(Object error);

  /// No description provided for @promoFormTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de promoción'**
  String get promoFormTypeLabel;

  /// No description provided for @promoFormTypeNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get promoFormTypeNormal;

  /// No description provided for @promoFormTypeFlash.
  ///
  /// In es, this message translates to:
  /// **'Flash ⚡'**
  String get promoFormTypeFlash;

  /// No description provided for @promoFormTypeBirthday.
  ///
  /// In es, this message translates to:
  /// **'Cumpleañero 🎂'**
  String get promoFormTypeBirthday;

  /// No description provided for @promoFormTypeNormalDesc.
  ///
  /// In es, this message translates to:
  /// **'Se repite cada semana en los días y horario elegidos.'**
  String get promoFormTypeNormalDesc;

  /// No description provided for @promoFormTypeFlashDesc.
  ///
  /// In es, this message translates to:
  /// **'Evento único, válido un solo día. Máximo 1 flash por mes.'**
  String get promoFormTypeFlashDesc;

  /// No description provided for @promoFormTypeBirthdayDesc.
  ///
  /// In es, this message translates to:
  /// **'Disponible todos los días del año para clientes que cumplan años.'**
  String get promoFormTypeBirthdayDesc;

  /// No description provided for @promoFormNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre *'**
  String get promoFormNameLabel;

  /// No description provided for @promoFormNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 2x1 en micheladas'**
  String get promoFormNameHint;

  /// No description provided for @promoFormDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get promoFormDescriptionLabel;

  /// No description provided for @promoFormDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Cuéntale a tus clientes los detalles'**
  String get promoFormDescriptionHint;

  /// No description provided for @promoFormBirthdayGiftLabel.
  ///
  /// In es, this message translates to:
  /// **'Regalo de cumpleaños *'**
  String get promoFormBirthdayGiftLabel;

  /// No description provided for @promoFormBirthdayGiftHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Postre gratis, copa de cortesía…'**
  String get promoFormBirthdayGiftHint;

  /// No description provided for @promoFormBirthdayTermsLabel.
  ///
  /// In es, this message translates to:
  /// **'Condiciones (opcional)'**
  String get promoFormBirthdayTermsLabel;

  /// No description provided for @promoFormBirthdayTermsHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Presentar ID el día de tu cumpleaños'**
  String get promoFormBirthdayTermsHint;

  /// No description provided for @promoFormPhotoLabel.
  ///
  /// In es, this message translates to:
  /// **'Foto (opcional)'**
  String get promoFormPhotoLabel;

  /// No description provided for @promoFormPhotoTapToAdd.
  ///
  /// In es, this message translates to:
  /// **'Toca para agregar foto'**
  String get promoFormPhotoTapToAdd;

  /// No description provided for @promoFormCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría (opcional)'**
  String get promoFormCategoryLabel;

  /// No description provided for @promoFormCategorySelected.
  ///
  /// In es, this message translates to:
  /// **'Categoría seleccionada'**
  String get promoFormCategorySelected;

  /// No description provided for @promoFormCategoryLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando categorías...'**
  String get promoFormCategoryLoading;

  /// No description provided for @promoFormCategoryNone.
  ///
  /// In es, this message translates to:
  /// **'Sin categoría'**
  String get promoFormCategoryNone;

  /// No description provided for @promoFormAdultTitle.
  ///
  /// In es, this message translates to:
  /// **'Contenido para adultos'**
  String get promoFormAdultTitle;

  /// No description provided for @promoFormAdultSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Solo visible para usuarios +18'**
  String get promoFormAdultSubtitle;

  /// No description provided for @promoFormSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get promoFormSaveChanges;

  /// No description provided for @promoFormCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear promoción'**
  String get promoFormCreate;

  /// No description provided for @promoFormActiveDaysLabel.
  ///
  /// In es, this message translates to:
  /// **'Días activos *'**
  String get promoFormActiveDaysLabel;

  /// No description provided for @promoFormScheduleLabel.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get promoFormScheduleLabel;

  /// No description provided for @promoFormStartLabel.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get promoFormStartLabel;

  /// No description provided for @promoFormEndLabel.
  ///
  /// In es, this message translates to:
  /// **'Fin'**
  String get promoFormEndLabel;

  /// No description provided for @promoFormEventStartLabel.
  ///
  /// In es, this message translates to:
  /// **'Inicio del evento *'**
  String get promoFormEventStartLabel;

  /// No description provided for @promoFormEventEndLabel.
  ///
  /// In es, this message translates to:
  /// **'Fin del evento *'**
  String get promoFormEventEndLabel;

  /// No description provided for @promoFormEndTimeSameDayLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora de fin * (mismo día)'**
  String get promoFormEndTimeSameDayLabel;

  /// No description provided for @promoFormPickDateTime.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fecha y hora'**
  String get promoFormPickDateTime;

  /// No description provided for @promoFormPickEndTime.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar hora de fin'**
  String get promoFormPickEndTime;

  /// No description provided for @promoFormFlashInfo.
  ///
  /// In es, this message translates to:
  /// **'La promo flash debe comenzar y terminar el mismo día. Solo se permite una por mes por negocio.'**
  String get promoFormFlashInfo;

  /// No description provided for @adminPlacesTitle.
  ///
  /// In es, this message translates to:
  /// **'Admin Lugares'**
  String get adminPlacesTitle;

  /// No description provided for @adminPlacesRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get adminPlacesRefresh;

  /// No description provided for @adminPlacesTabEstablishments.
  ///
  /// In es, this message translates to:
  /// **'Establecimientos'**
  String get adminPlacesTabEstablishments;

  /// No description provided for @adminPlacesTabPromos.
  ///
  /// In es, this message translates to:
  /// **'Promociones'**
  String get adminPlacesTabPromos;

  /// No description provided for @adminPlacesAddPlace.
  ///
  /// In es, this message translates to:
  /// **'Agregar lugar'**
  String get adminPlacesAddPlace;

  /// No description provided for @adminPlacesSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar…'**
  String get adminPlacesSearchHint;

  /// No description provided for @adminPlacesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 lugar} other{{count} lugares}}'**
  String adminPlacesCount(num count);

  /// No description provided for @adminPlacesEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay lugares. Toca + para agregar uno.'**
  String get adminPlacesEmpty;

  /// No description provided for @adminPlacesNoResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados.'**
  String get adminPlacesNoResults;

  /// No description provided for @adminPlacesEditInfo.
  ///
  /// In es, this message translates to:
  /// **'Editar info'**
  String get adminPlacesEditInfo;

  /// No description provided for @adminPlacesManagePhotos.
  ///
  /// In es, this message translates to:
  /// **'Gestionar fotos'**
  String get adminPlacesManagePhotos;

  /// No description provided for @adminPlacesDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get adminPlacesDelete;

  /// No description provided for @adminPlacesManagePromos.
  ///
  /// In es, this message translates to:
  /// **'Gestionar promociones'**
  String get adminPlacesManagePromos;

  /// No description provided for @adminPlacesPhotosTitle.
  ///
  /// In es, this message translates to:
  /// **'Fotos — {name}'**
  String adminPlacesPhotosTitle(Object name);

  /// No description provided for @adminPlacesDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar lugar'**
  String get adminPlacesDeleteTitle;

  /// No description provided for @adminPlacesDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"?\nTambién eliminará sus promociones.'**
  String adminPlacesDeleteConfirm(Object name);

  /// No description provided for @adminPlacesCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get adminPlacesCancel;

  /// No description provided for @adminPlacesError.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String adminPlacesError(Object error);

  /// No description provided for @adminPlacesNoPlacesYet.
  ///
  /// In es, this message translates to:
  /// **'Primero crea un lugar en la pestaña Establecimientos.'**
  String get adminPlacesNoPlacesYet;

  /// No description provided for @adminPlacesSelectPlace.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un lugar'**
  String get adminPlacesSelectPlace;

  /// No description provided for @adminPlacesNewPromo.
  ///
  /// In es, this message translates to:
  /// **'Nueva promoción'**
  String get adminPlacesNewPromo;

  /// No description provided for @adminPlacesChoosePlace.
  ///
  /// In es, this message translates to:
  /// **'Elige un lugar para ver sus promociones.'**
  String get adminPlacesChoosePlace;

  /// No description provided for @adminPlacesNoPromos.
  ///
  /// In es, this message translates to:
  /// **'Sin promociones. Toca \"Nueva promoción\".'**
  String get adminPlacesNoPromos;

  /// No description provided for @adminPlacesPromoActive.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get adminPlacesPromoActive;

  /// No description provided for @adminPlacesPromoInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactiva'**
  String get adminPlacesPromoInactive;

  /// No description provided for @adminPlacesEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get adminPlacesEdit;

  /// No description provided for @adminMetricsTitle.
  ///
  /// In es, this message translates to:
  /// **'Panel Admin'**
  String get adminMetricsTitle;

  /// No description provided for @adminMetricsManageRestaurants.
  ///
  /// In es, this message translates to:
  /// **'Gestionar restaurantes'**
  String get adminMetricsManageRestaurants;

  /// No description provided for @adminMetricsRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar métricas'**
  String get adminMetricsRefresh;

  /// No description provided for @adminMetricsRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get adminMetricsRetry;

  /// No description provided for @adminMetricsAdminPlaces.
  ///
  /// In es, this message translates to:
  /// **'Admin Lugares'**
  String get adminMetricsAdminPlaces;

  /// No description provided for @adminMetricsAdminPlacesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar establecimientos y promociones del admin'**
  String get adminMetricsAdminPlacesSubtitle;

  /// No description provided for @adminMetricsSectionUsers.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get adminMetricsSectionUsers;

  /// No description provided for @adminMetricsNewUsers.
  ///
  /// In es, this message translates to:
  /// **'Nuevos usuarios'**
  String get adminMetricsNewUsers;

  /// No description provided for @adminMetricsActiveUsers.
  ///
  /// In es, this message translates to:
  /// **'Usuarios activos'**
  String get adminMetricsActiveUsers;

  /// No description provided for @adminMetricsPeriodToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get adminMetricsPeriodToday;

  /// No description provided for @adminMetricsPeriod7d.
  ///
  /// In es, this message translates to:
  /// **'7 días'**
  String get adminMetricsPeriod7d;

  /// No description provided for @adminMetricsPeriod15d.
  ///
  /// In es, this message translates to:
  /// **'15 días'**
  String get adminMetricsPeriod15d;

  /// No description provided for @adminMetricsPeriod30d.
  ///
  /// In es, this message translates to:
  /// **'30 días'**
  String get adminMetricsPeriod30d;

  /// No description provided for @adminMetricsPeriodTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get adminMetricsPeriodTotal;

  /// No description provided for @adminMetricsSectionPlatform.
  ///
  /// In es, this message translates to:
  /// **'Plataforma'**
  String get adminMetricsSectionPlatform;

  /// No description provided for @adminMetricsEstablishments.
  ///
  /// In es, this message translates to:
  /// **'Establecimientos'**
  String get adminMetricsEstablishments;

  /// No description provided for @adminMetricsNewThisMonth.
  ///
  /// In es, this message translates to:
  /// **'{count} este mes'**
  String adminMetricsNewThisMonth(Object count);

  /// No description provided for @adminMetricsActivePromos.
  ///
  /// In es, this message translates to:
  /// **'Promos activas'**
  String get adminMetricsActivePromos;

  /// No description provided for @adminMetricsTotalCount.
  ///
  /// In es, this message translates to:
  /// **'{count} total'**
  String adminMetricsTotalCount(Object count);

  /// No description provided for @adminMetricsSectionLoyaltyQr.
  ///
  /// In es, this message translates to:
  /// **'Lealtad & QR'**
  String get adminMetricsSectionLoyaltyQr;

  /// No description provided for @adminMetricsTotalScans.
  ///
  /// In es, this message translates to:
  /// **'Escaneos totales'**
  String get adminMetricsTotalScans;

  /// No description provided for @adminMetricsLast30dValue.
  ///
  /// In es, this message translates to:
  /// **'{count} últimos 30d'**
  String adminMetricsLast30dValue(Object count);

  /// No description provided for @adminMetricsAvgTicket.
  ///
  /// In es, this message translates to:
  /// **'Ticket promedio'**
  String get adminMetricsAvgTicket;

  /// No description provided for @adminMetricsWaiterUploadedAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto subido por meseros'**
  String get adminMetricsWaiterUploadedAmount;

  /// No description provided for @adminMetricsSectionCampaigns.
  ///
  /// In es, this message translates to:
  /// **'Campañas Publicitarias'**
  String get adminMetricsSectionCampaigns;

  /// No description provided for @adminMetricsActiveCampaigns.
  ///
  /// In es, this message translates to:
  /// **'Campañas activas'**
  String get adminMetricsActiveCampaigns;

  /// No description provided for @adminMetricsCreditsSold.
  ///
  /// In es, this message translates to:
  /// **'Créditos vendidos'**
  String get adminMetricsCreditsSold;

  /// No description provided for @adminMetricsLast30days.
  ///
  /// In es, this message translates to:
  /// **'últimos 30 días'**
  String get adminMetricsLast30days;

  /// No description provided for @adminMetricsCampaignSpend.
  ///
  /// In es, this message translates to:
  /// **'Gasto en campañas'**
  String get adminMetricsCampaignSpend;

  /// No description provided for @adminMetricsSectionSubscriptions.
  ///
  /// In es, this message translates to:
  /// **'Suscripciones'**
  String get adminMetricsSectionSubscriptions;

  /// No description provided for @adminMetricsActiveSubscriptions.
  ///
  /// In es, this message translates to:
  /// **'Suscripciones activas'**
  String get adminMetricsActiveSubscriptions;

  /// No description provided for @adminMetricsMonthlyIncome.
  ///
  /// In es, this message translates to:
  /// **'ingresos mensuales'**
  String get adminMetricsMonthlyIncome;

  /// No description provided for @adminMetricsSectionPerformance.
  ///
  /// In es, this message translates to:
  /// **'Rendimiento'**
  String get adminMetricsSectionPerformance;

  /// No description provided for @adminMetricsRegisteredUsers.
  ///
  /// In es, this message translates to:
  /// **'usuarios registrados'**
  String get adminMetricsRegisteredUsers;

  /// No description provided for @adminMetricsRoleUsers.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get adminMetricsRoleUsers;

  /// No description provided for @adminMetricsRoleStaff.
  ///
  /// In es, this message translates to:
  /// **'Staff'**
  String get adminMetricsRoleStaff;

  /// No description provided for @adminMetricsRoleBusiness.
  ///
  /// In es, this message translates to:
  /// **'Negocios'**
  String get adminMetricsRoleBusiness;

  /// No description provided for @adminMetricsRoleAdmin.
  ///
  /// In es, this message translates to:
  /// **'Admin'**
  String get adminMetricsRoleAdmin;

  /// No description provided for @adminMetricsPlatformRevenue30d.
  ///
  /// In es, this message translates to:
  /// **'Ingresos plataforma (30 días)'**
  String get adminMetricsPlatformRevenue30d;

  /// No description provided for @adminMetricsRevenueSubscriptions.
  ///
  /// In es, this message translates to:
  /// **'Suscripciones\n(MRR)'**
  String get adminMetricsRevenueSubscriptions;

  /// No description provided for @adminMetricsRevenueAdCredits.
  ///
  /// In es, this message translates to:
  /// **'Créditos ad\n(30d)'**
  String get adminMetricsRevenueAdCredits;

  /// No description provided for @adminMetricsRevenueRoas.
  ///
  /// In es, this message translates to:
  /// **'ROAS\n(ingresos/gasto ad)'**
  String get adminMetricsRevenueRoas;

  /// No description provided for @adminMetricsNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'N/A'**
  String get adminMetricsNotAvailable;

  /// No description provided for @adminEstTitle.
  ///
  /// In es, this message translates to:
  /// **'Restaurantes Admin'**
  String get adminEstTitle;

  /// No description provided for @adminEstRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get adminEstRefresh;

  /// No description provided for @adminEstAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar restaurante'**
  String get adminEstAdd;

  /// No description provided for @adminEstSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre o dirección…'**
  String get adminEstSearchHint;

  /// No description provided for @adminEstLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get adminEstLoading;

  /// No description provided for @adminEstCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 establecimiento} other{{count} establecimientos}}'**
  String adminEstCount(num count);

  /// No description provided for @adminEstRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get adminEstRetry;

  /// No description provided for @adminEstEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay restaurantes gestionados por Admin.'**
  String get adminEstEmpty;

  /// No description provided for @adminEstNoResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados para \"{query}\".'**
  String adminEstNoResults(Object query);

  /// No description provided for @adminEstAddFirst.
  ///
  /// In es, this message translates to:
  /// **'Agregar primero'**
  String get adminEstAddFirst;

  /// No description provided for @adminEstDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar restaurante'**
  String get adminEstDeleteTitle;

  /// No description provided for @adminEstDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"?\nEsto también eliminará sus promociones y datos asociados.'**
  String adminEstDeleteConfirm(Object name);

  /// No description provided for @adminEstCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get adminEstCancel;

  /// No description provided for @adminEstDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get adminEstDelete;

  /// No description provided for @adminEstDeleted.
  ///
  /// In es, this message translates to:
  /// **'\"{name}\" eliminado.'**
  String adminEstDeleted(Object name);

  /// No description provided for @adminEstDeleteError.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar: {error}'**
  String adminEstDeleteError(Object error);

  /// No description provided for @adminEstEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get adminEstEdit;

  /// No description provided for @statsTitle.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statsTitle;

  /// No description provided for @statsRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get statsRetry;

  /// No description provided for @statsBusinessViews.
  ///
  /// In es, this message translates to:
  /// **'Vistas negocio'**
  String get statsBusinessViews;

  /// No description provided for @statsPromoViews.
  ///
  /// In es, this message translates to:
  /// **'Vistas promos'**
  String get statsPromoViews;

  /// No description provided for @statsNewFavs.
  ///
  /// In es, this message translates to:
  /// **'Nuevos favs'**
  String get statsNewFavs;

  /// No description provided for @statsContacts.
  ///
  /// In es, this message translates to:
  /// **'Contactos'**
  String get statsContacts;

  /// No description provided for @statsQrVisits.
  ///
  /// In es, this message translates to:
  /// **'Visitas QR'**
  String get statsQrVisits;

  /// No description provided for @statsTotalFavs.
  ///
  /// In es, this message translates to:
  /// **'Favs totales'**
  String get statsTotalFavs;

  /// No description provided for @statsAvgTicket.
  ///
  /// In es, this message translates to:
  /// **'Ticket prom.'**
  String get statsAvgTicket;

  /// No description provided for @statsRevenue.
  ///
  /// In es, this message translates to:
  /// **'Ingresos generados'**
  String get statsRevenue;

  /// No description provided for @statsPromoBreakdown.
  ///
  /// In es, this message translates to:
  /// **'DETALLE POR PROMO'**
  String get statsPromoBreakdown;

  /// No description provided for @statsColPromo.
  ///
  /// In es, this message translates to:
  /// **'Promo'**
  String get statsColPromo;

  /// No description provided for @statsColViews.
  ///
  /// In es, this message translates to:
  /// **'Vistas'**
  String get statsColViews;

  /// No description provided for @statsColViewsTooltip.
  ///
  /// In es, this message translates to:
  /// **'Veces que abrieron el detalle'**
  String get statsColViewsTooltip;

  /// No description provided for @statsColNewFavs.
  ///
  /// In es, this message translates to:
  /// **'Favs +'**
  String get statsColNewFavs;

  /// No description provided for @statsColNewFavsTooltip.
  ///
  /// In es, this message translates to:
  /// **'Nuevos favoritos en el período'**
  String get statsColNewFavsTooltip;

  /// No description provided for @statsColTotalFavs.
  ///
  /// In es, this message translates to:
  /// **'Favs Σ'**
  String get statsColTotalFavs;

  /// No description provided for @statsColTotalFavsTooltip.
  ///
  /// In es, this message translates to:
  /// **'Total de favoritos acumulados'**
  String get statsColTotalFavsTooltip;

  /// No description provided for @statsContactChannels.
  ///
  /// In es, this message translates to:
  /// **'CANALES DE CONTACTO'**
  String get statsContactChannels;

  /// No description provided for @statsChannelPhone.
  ///
  /// In es, this message translates to:
  /// **'Llamada'**
  String get statsChannelPhone;

  /// No description provided for @statsChannelWebsite.
  ///
  /// In es, this message translates to:
  /// **'Sitio web'**
  String get statsChannelWebsite;

  /// No description provided for @statsChannelMaps.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get statsChannelMaps;

  /// No description provided for @statsAudienceHeader.
  ///
  /// In es, this message translates to:
  /// **'AUDIENCIA ({total} favoriteadores)'**
  String statsAudienceHeader(Object total);

  /// No description provided for @statsGender.
  ///
  /// In es, this message translates to:
  /// **'Sexo'**
  String get statsGender;

  /// No description provided for @statsAge.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get statsAge;

  /// No description provided for @statsByPromo.
  ///
  /// In es, this message translates to:
  /// **'Por promoción'**
  String get statsByPromo;

  /// No description provided for @statsGenderMale.
  ///
  /// In es, this message translates to:
  /// **'Hombres'**
  String get statsGenderMale;

  /// No description provided for @statsGenderFemale.
  ///
  /// In es, this message translates to:
  /// **'Mujeres'**
  String get statsGenderFemale;

  /// No description provided for @statsGenderUnknown.
  ///
  /// In es, this message translates to:
  /// **'N/E'**
  String get statsGenderUnknown;

  /// No description provided for @photosSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Logo y fotos'**
  String get photosSectionTitle;

  /// No description provided for @photosLogoTitle.
  ///
  /// In es, this message translates to:
  /// **'Logo del negocio'**
  String get photosLogoTitle;

  /// No description provided for @photosLogoHint.
  ///
  /// In es, this message translates to:
  /// **'Imagen cuadrada, mínimo 400×400 px.'**
  String get photosLogoHint;

  /// No description provided for @photosChangeLogo.
  ///
  /// In es, this message translates to:
  /// **'Cambiar logo'**
  String get photosChangeLogo;

  /// No description provided for @photosUploadLogo.
  ///
  /// In es, this message translates to:
  /// **'Subir logo'**
  String get photosUploadLogo;

  /// No description provided for @photosCategoryEstablishment.
  ///
  /// In es, this message translates to:
  /// **'Fotos del establecimiento'**
  String get photosCategoryEstablishment;

  /// No description provided for @photosCategoryChildrenArea.
  ///
  /// In es, this message translates to:
  /// **'Área infantil'**
  String get photosCategoryChildrenArea;

  /// No description provided for @photosCategoryMenu.
  ///
  /// In es, this message translates to:
  /// **'Menú'**
  String get photosCategoryMenu;

  /// No description provided for @photosEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin fotos'**
  String get photosEmpty;

  /// No description provided for @photosDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar foto'**
  String get photosDeleteTitle;

  /// No description provided for @photosDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres eliminar esta foto?'**
  String get photosDeleteConfirm;

  /// No description provided for @photosCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get photosCancel;

  /// No description provided for @photosDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get photosDelete;

  /// No description provided for @photosErrorUploadLogo.
  ///
  /// In es, this message translates to:
  /// **'No se pudo subir el logo. Intenta de nuevo.'**
  String get photosErrorUploadLogo;

  /// No description provided for @photosErrorUploadPhoto.
  ///
  /// In es, this message translates to:
  /// **'No se pudo subir la foto. Intenta de nuevo.'**
  String get photosErrorUploadPhoto;

  /// No description provided for @photosErrorDeletePhoto.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar la foto. Intenta de nuevo.'**
  String get photosErrorDeletePhoto;

  /// No description provided for @adminPanelTitle.
  ///
  /// In es, this message translates to:
  /// **'Panel Superadmin'**
  String get adminPanelTitle;

  /// No description provided for @adminReload.
  ///
  /// In es, this message translates to:
  /// **'Recargar'**
  String get adminReload;

  /// No description provided for @adminLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar'**
  String get adminLoadError;

  /// No description provided for @adminRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get adminRetry;

  /// No description provided for @adminSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Administración'**
  String get adminSectionTitle;

  /// No description provided for @adminTilePlans.
  ///
  /// In es, this message translates to:
  /// **'Planes de membresía'**
  String get adminTilePlans;

  /// No description provided for @adminTilePlansSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{count} planes configurados'**
  String adminTilePlansSubtitle(Object count);

  /// No description provided for @adminTileOwners.
  ///
  /// In es, this message translates to:
  /// **'Dueños de negocio'**
  String get adminTileOwners;

  /// No description provided for @adminTileOwnersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{count} propietarios registrados'**
  String adminTileOwnersSubtitle(Object count);

  /// No description provided for @adminTileCategories.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get adminTileCategories;

  /// No description provided for @adminTileCategoriesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{count} categorías · árbol de tipos'**
  String adminTileCategoriesSubtitle(Object count);

  /// No description provided for @adminTileCharacteristics.
  ///
  /// In es, this message translates to:
  /// **'Características'**
  String get adminTileCharacteristics;

  /// No description provided for @adminTileCharacteristicsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{count} características'**
  String adminTileCharacteristicsSubtitle(Object count);

  /// No description provided for @adminTileNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones push'**
  String get adminTileNotifications;

  /// No description provided for @adminTileNotificationsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{devices} dispositivos · {sends} envíos registrados'**
  String adminTileNotificationsSubtitle(Object devices, Object sends);

  /// No description provided for @adminTileAllUsers.
  ///
  /// In es, this message translates to:
  /// **'Todos los usuarios'**
  String get adminTileAllUsers;

  /// No description provided for @adminTileAllUsersSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar cuentas · activar / desactivar'**
  String get adminTileAllUsersSubtitle;

  /// No description provided for @adminTileAds.
  ///
  /// In es, this message translates to:
  /// **'Publicidad'**
  String get adminTileAds;

  /// No description provided for @adminTileAdsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Precios por formato · gestión de campañas'**
  String get adminTileAdsSubtitle;

  /// No description provided for @adminTileCredits.
  ///
  /// In es, this message translates to:
  /// **'Créditos publicitarios'**
  String get adminTileCredits;

  /// No description provided for @adminTileCreditsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Asignar saldo a cuentas de establecimientos'**
  String get adminTileCreditsSubtitle;

  /// No description provided for @adminTileBulk.
  ///
  /// In es, this message translates to:
  /// **'Carga masiva de promos'**
  String get adminTileBulk;

  /// No description provided for @adminTileBulkSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crear promociones para negocios · no cuenta contra el plan'**
  String get adminTileBulkSubtitle;

  /// No description provided for @adminRoleFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get adminRoleFilterAll;

  /// No description provided for @adminRoleFilterUsers.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get adminRoleFilterUsers;

  /// No description provided for @adminRoleFilterStaff.
  ///
  /// In es, this message translates to:
  /// **'Staff'**
  String get adminRoleFilterStaff;

  /// No description provided for @adminRoleFilterOwners.
  ///
  /// In es, this message translates to:
  /// **'Dueños'**
  String get adminRoleFilterOwners;

  /// No description provided for @adminRoleFilterAdmin.
  ///
  /// In es, this message translates to:
  /// **'Admin'**
  String get adminRoleFilterAdmin;

  /// No description provided for @adminErrorWithMsg.
  ///
  /// In es, this message translates to:
  /// **'Error: {msg}'**
  String adminErrorWithMsg(Object msg);

  /// No description provided for @adminAllUsersTitle.
  ///
  /// In es, this message translates to:
  /// **'Todos los usuarios'**
  String get adminAllUsersTitle;

  /// No description provided for @adminSearchNameEmail.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre o correo…'**
  String get adminSearchNameEmail;

  /// No description provided for @adminUserCount.
  ///
  /// In es, this message translates to:
  /// **'{count} usuario(s)'**
  String adminUserCount(Object count);

  /// No description provided for @adminNoResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get adminNoResults;

  /// No description provided for @adminAccountDeactivated.
  ///
  /// In es, this message translates to:
  /// **'Cuenta desactivada'**
  String get adminAccountDeactivated;

  /// No description provided for @adminActivate.
  ///
  /// In es, this message translates to:
  /// **'Activar'**
  String get adminActivate;

  /// No description provided for @adminDeactivate.
  ///
  /// In es, this message translates to:
  /// **'Desactivar'**
  String get adminDeactivate;

  /// No description provided for @adminActivateAccount.
  ///
  /// In es, this message translates to:
  /// **'Activar cuenta'**
  String get adminActivateAccount;

  /// No description provided for @adminDeactivateAccount.
  ///
  /// In es, this message translates to:
  /// **'Desactivar cuenta'**
  String get adminDeactivateAccount;

  /// No description provided for @adminActivateAccountConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Reactivar la cuenta de {name}? Podrá volver a iniciar sesión.'**
  String adminActivateAccountConfirm(Object name);

  /// No description provided for @adminDeactivateAccountConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Desactivar la cuenta de {name}? No podrá iniciar sesión ni aparecerá su contenido.'**
  String adminDeactivateAccountConfirm(Object name);

  /// No description provided for @adminCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get adminCancel;

  /// No description provided for @adminPlansTitle.
  ///
  /// In es, this message translates to:
  /// **'Planes de membresía'**
  String get adminPlansTitle;

  /// No description provided for @adminAddons.
  ///
  /// In es, this message translates to:
  /// **'Add-ons'**
  String get adminAddons;

  /// No description provided for @adminAddonsDesc.
  ///
  /// In es, this message translates to:
  /// **'Precios por unidad/mes que se cobran por encima del límite del plan.'**
  String get adminAddonsDesc;

  /// No description provided for @adminAddonTableMissing.
  ///
  /// In es, this message translates to:
  /// **'Tabla addon_pricing no encontrada.'**
  String get adminAddonTableMissing;

  /// No description provided for @adminAddonRunSql.
  ///
  /// In es, this message translates to:
  /// **'Ejecuta el SQL de add-ons en Supabase primero.'**
  String get adminAddonRunSql;

  /// No description provided for @adminOwnersTitle.
  ///
  /// In es, this message translates to:
  /// **'Dueños de negocio'**
  String get adminOwnersTitle;

  /// No description provided for @adminResultCount.
  ///
  /// In es, this message translates to:
  /// **'{count} resultado(s)'**
  String adminResultCount(Object count);

  /// No description provided for @adminCategoriesTitle.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get adminCategoriesTitle;

  /// No description provided for @adminNewRootType.
  ///
  /// In es, this message translates to:
  /// **'Nuevo tipo raíz'**
  String get adminNewRootType;

  /// No description provided for @adminNoCategories.
  ///
  /// In es, this message translates to:
  /// **'Sin categorías'**
  String get adminNoCategories;

  /// No description provided for @adminLevelType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get adminLevelType;

  /// No description provided for @adminLevelSubtype.
  ///
  /// In es, this message translates to:
  /// **'Subtipo'**
  String get adminLevelSubtype;

  /// No description provided for @adminLevelSubSubtype.
  ///
  /// In es, this message translates to:
  /// **'Sub-subtipo'**
  String get adminLevelSubSubtype;

  /// No description provided for @adminAddSubcategory.
  ///
  /// In es, this message translates to:
  /// **'Agregar subcategoría'**
  String get adminAddSubcategory;

  /// No description provided for @adminDeleteCategory.
  ///
  /// In es, this message translates to:
  /// **'Eliminar categoría'**
  String get adminDeleteCategory;

  /// No description provided for @adminDeleteCategoryWithChildren.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"? También se eliminarán sus {count} subcategoría(s).'**
  String adminDeleteCategoryWithChildren(Object name, Object count);

  /// No description provided for @adminDeleteCategorySimple.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"?'**
  String adminDeleteCategorySimple(Object name);

  /// No description provided for @adminDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get adminDelete;

  /// No description provided for @adminCharacteristicsTitle.
  ///
  /// In es, this message translates to:
  /// **'Características'**
  String get adminCharacteristicsTitle;

  /// No description provided for @adminNewCharacteristic.
  ///
  /// In es, this message translates to:
  /// **'Nueva característica'**
  String get adminNewCharacteristic;

  /// No description provided for @adminNoCharacteristics.
  ///
  /// In es, this message translates to:
  /// **'Sin características'**
  String get adminNoCharacteristics;

  /// No description provided for @adminDeleteCharacteristic.
  ///
  /// In es, this message translates to:
  /// **'Eliminar característica'**
  String get adminDeleteCharacteristic;

  /// No description provided for @adminDeleteCharacteristicConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar \"{name}\"? Se quitará de todos los establecimientos.'**
  String adminDeleteCharacteristicConfirm(Object name);

  /// No description provided for @adminFree.
  ///
  /// In es, this message translates to:
  /// **'Gratis'**
  String get adminFree;

  /// No description provided for @adminPricePerMonth.
  ///
  /// In es, this message translates to:
  /// **'\${price} MXN/mes'**
  String adminPricePerMonth(Object price);

  /// No description provided for @adminBusinessCount.
  ///
  /// In es, this message translates to:
  /// **'{count} negocio(s)'**
  String adminBusinessCount(Object count);

  /// No description provided for @adminPromoCount.
  ///
  /// In es, this message translates to:
  /// **'{count} promo(s)'**
  String adminPromoCount(Object count);

  /// No description provided for @adminEditPlan.
  ///
  /// In es, this message translates to:
  /// **'Editar plan'**
  String get adminEditPlan;

  /// No description provided for @adminFreeNoCharge.
  ///
  /// In es, this message translates to:
  /// **'Gratis / sin cargo'**
  String get adminFreeNoCharge;

  /// No description provided for @adminEditPrice.
  ///
  /// In es, this message translates to:
  /// **'Editar precio'**
  String get adminEditPrice;

  /// No description provided for @adminEditLabel.
  ///
  /// In es, this message translates to:
  /// **'Editar: {label}'**
  String adminEditLabel(Object label);

  /// No description provided for @adminInvalidPriceMin.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un precio válido (0 o mayor).'**
  String get adminInvalidPriceMin;

  /// No description provided for @adminMonthlyPricePerUnit.
  ///
  /// In es, this message translates to:
  /// **'Precio mensual por unidad (MXN)'**
  String get adminMonthlyPricePerUnit;

  /// No description provided for @adminNoAdditionalCharge.
  ///
  /// In es, this message translates to:
  /// **'0 = sin cargo adicional'**
  String get adminNoAdditionalCharge;

  /// No description provided for @adminAddonZeroHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe 0 si el add-on es gratuito o aún no está activo.'**
  String get adminAddonZeroHint;

  /// No description provided for @adminSavePrice.
  ///
  /// In es, this message translates to:
  /// **'Guardar precio'**
  String get adminSavePrice;

  /// No description provided for @adminEditPlanLabel.
  ///
  /// In es, this message translates to:
  /// **'Editar plan: {name}'**
  String adminEditPlanLabel(Object name);

  /// No description provided for @adminPriceMxnMonth.
  ///
  /// In es, this message translates to:
  /// **'Precio (MXN/mes)'**
  String get adminPriceMxnMonth;

  /// No description provided for @adminZeroForFree.
  ///
  /// In es, this message translates to:
  /// **'0 para plan gratuito'**
  String get adminZeroForFree;

  /// No description provided for @adminMaxEstablishments.
  ///
  /// In es, this message translates to:
  /// **'Máx. establecimientos'**
  String get adminMaxEstablishments;

  /// No description provided for @adminMaxActivePromos.
  ///
  /// In es, this message translates to:
  /// **'Máx. promociones activas'**
  String get adminMaxActivePromos;

  /// No description provided for @adminSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get adminSaveChanges;

  /// No description provided for @adminPlanPickerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'\${price} MXN/mes · {est} neg. · {promos} promos'**
  String adminPlanPickerSubtitle(Object price, Object est, Object promos);

  /// No description provided for @adminEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get adminEdit;

  /// No description provided for @adminNameEmpty.
  ///
  /// In es, this message translates to:
  /// **'El nombre no puede estar vacío.'**
  String get adminNameEmpty;

  /// No description provided for @adminNewCategory.
  ///
  /// In es, this message translates to:
  /// **'Nueva categoría'**
  String get adminNewCategory;

  /// No description provided for @adminEditCategory.
  ///
  /// In es, this message translates to:
  /// **'Editar categoría'**
  String get adminEditCategory;

  /// No description provided for @adminNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Nombre *'**
  String get adminNameRequired;

  /// No description provided for @adminEmojiIcon.
  ///
  /// In es, this message translates to:
  /// **'Emoji / ícono'**
  String get adminEmojiIcon;

  /// No description provided for @adminBelongsToParent.
  ///
  /// In es, this message translates to:
  /// **'Pertenece a (padre)'**
  String get adminBelongsToParent;

  /// No description provided for @adminNoParentRoot.
  ///
  /// In es, this message translates to:
  /// **'— Sin padre (Tipo raíz) —'**
  String get adminNoParentRoot;

  /// No description provided for @adminCreateCategory.
  ///
  /// In es, this message translates to:
  /// **'Crear categoría'**
  String get adminCreateCategory;

  /// No description provided for @adminEditCharacteristic.
  ///
  /// In es, this message translates to:
  /// **'Editar característica'**
  String get adminEditCharacteristic;

  /// No description provided for @adminCreateCharacteristic.
  ///
  /// In es, this message translates to:
  /// **'Crear característica'**
  String get adminCreateCharacteristic;

  /// No description provided for @adminNotificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones push'**
  String get adminNotificationsTitle;

  /// No description provided for @adminTabSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get adminTabSend;

  /// No description provided for @adminTabScheduled.
  ///
  /// In es, this message translates to:
  /// **'Programadas'**
  String get adminTabScheduled;

  /// No description provided for @adminTabHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get adminTabHistory;

  /// No description provided for @adminTabMetrics.
  ///
  /// In es, this message translates to:
  /// **'Métricas'**
  String get adminTabMetrics;

  /// No description provided for @adminCompleteTitleBody.
  ///
  /// In es, this message translates to:
  /// **'Completa título y mensaje'**
  String get adminCompleteTitleBody;

  /// No description provided for @adminCompleteTitleBodyBeforeSchedule.
  ///
  /// In es, this message translates to:
  /// **'Completa título y mensaje antes de programar'**
  String get adminCompleteTitleBodyBeforeSchedule;

  /// No description provided for @adminSentResult.
  ///
  /// In es, this message translates to:
  /// **'✅ Enviada a {count} dispositivos'**
  String adminSentResult(Object count);

  /// No description provided for @adminSentResultWithFailed.
  ///
  /// In es, this message translates to:
  /// **'✅ Enviada a {count} dispositivos · {failed} fallidos'**
  String adminSentResultWithFailed(Object count, Object failed);

  /// No description provided for @adminSendErrorResult.
  ///
  /// In es, this message translates to:
  /// **'❌ Error: {msg}'**
  String adminSendErrorResult(Object msg);

  /// No description provided for @adminScheduledOk.
  ///
  /// In es, this message translates to:
  /// **'📅 Notificación programada correctamente'**
  String get adminScheduledOk;

  /// No description provided for @adminTotalDevices.
  ///
  /// In es, this message translates to:
  /// **'Total: {count} dispositivos'**
  String adminTotalDevices(Object count);

  /// No description provided for @adminTitleRequired.
  ///
  /// In es, this message translates to:
  /// **'Título *'**
  String get adminTitleRequired;

  /// No description provided for @adminTitleHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Nueva función disponible'**
  String get adminTitleHint;

  /// No description provided for @adminMessageRequired.
  ///
  /// In es, this message translates to:
  /// **'Mensaje *'**
  String get adminMessageRequired;

  /// No description provided for @adminBodyHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe el cuerpo…'**
  String get adminBodyHint;

  /// No description provided for @adminSegmentRecipients.
  ///
  /// In es, this message translates to:
  /// **'Segmentar destinatarios'**
  String get adminSegmentRecipients;

  /// No description provided for @adminGender.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get adminGender;

  /// No description provided for @adminAllGenders.
  ///
  /// In es, this message translates to:
  /// **'Todos los géneros'**
  String get adminAllGenders;

  /// No description provided for @adminAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get adminAll;

  /// No description provided for @adminMen.
  ///
  /// In es, this message translates to:
  /// **'Hombres'**
  String get adminMen;

  /// No description provided for @adminWomen.
  ///
  /// In es, this message translates to:
  /// **'Mujeres'**
  String get adminWomen;

  /// No description provided for @adminPreferNotToSay.
  ///
  /// In es, this message translates to:
  /// **'Prefieren no decir'**
  String get adminPreferNotToSay;

  /// No description provided for @adminAgeRange.
  ///
  /// In es, this message translates to:
  /// **'Rango de edad'**
  String get adminAgeRange;

  /// No description provided for @adminMin.
  ///
  /// In es, this message translates to:
  /// **'Mín'**
  String get adminMin;

  /// No description provided for @adminMax.
  ///
  /// In es, this message translates to:
  /// **'Máx'**
  String get adminMax;

  /// No description provided for @adminInactiveUsersSince.
  ///
  /// In es, this message translates to:
  /// **'Usuarios inactivos desde hace'**
  String get adminInactiveUsersSince;

  /// No description provided for @adminNoFilter.
  ///
  /// In es, this message translates to:
  /// **'No filtrar'**
  String get adminNoFilter;

  /// No description provided for @adminDays7.
  ///
  /// In es, this message translates to:
  /// **'7 días'**
  String get adminDays7;

  /// No description provided for @adminDays15.
  ///
  /// In es, this message translates to:
  /// **'15 días'**
  String get adminDays15;

  /// No description provided for @adminDays30.
  ///
  /// In es, this message translates to:
  /// **'30 días'**
  String get adminDays30;

  /// No description provided for @adminDays60.
  ///
  /// In es, this message translates to:
  /// **'60 días'**
  String get adminDays60;

  /// No description provided for @adminDays90Plus.
  ///
  /// In es, this message translates to:
  /// **'90 días o más'**
  String get adminDays90Plus;

  /// No description provided for @adminPlatform.
  ///
  /// In es, this message translates to:
  /// **'Plataforma'**
  String get adminPlatform;

  /// No description provided for @adminAllFem.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get adminAllFem;

  /// No description provided for @adminCalculating.
  ///
  /// In es, this message translates to:
  /// **'Calculando…'**
  String get adminCalculating;

  /// No description provided for @adminRecipientsApprox.
  ///
  /// In es, this message translates to:
  /// **'~{count} destinatarios'**
  String adminRecipientsApprox(Object count);

  /// No description provided for @adminEstimateRecipients.
  ///
  /// In es, this message translates to:
  /// **'Estimar destinatarios'**
  String get adminEstimateRecipients;

  /// No description provided for @adminSchedule.
  ///
  /// In es, this message translates to:
  /// **'Programar'**
  String get adminSchedule;

  /// No description provided for @adminSending.
  ///
  /// In es, this message translates to:
  /// **'Enviando…'**
  String get adminSending;

  /// No description provided for @adminSendNow.
  ///
  /// In es, this message translates to:
  /// **'Enviar ahora'**
  String get adminSendNow;

  /// No description provided for @adminNoScheduled.
  ///
  /// In es, this message translates to:
  /// **'Sin notificaciones programadas'**
  String get adminNoScheduled;

  /// No description provided for @adminNoScheduledHint.
  ///
  /// In es, this message translates to:
  /// **'Usa la pestaña Enviar → Programar'**
  String get adminNoScheduledHint;

  /// No description provided for @adminNextSend.
  ///
  /// In es, this message translates to:
  /// **'Próximo: {date}'**
  String adminNextSend(Object date);

  /// No description provided for @adminRunCount.
  ///
  /// In es, this message translates to:
  /// **'{count} ejecución(es)'**
  String adminRunCount(Object count);

  /// No description provided for @adminNoSends.
  ///
  /// In es, this message translates to:
  /// **'Sin envíos registrados.'**
  String get adminNoSends;

  /// No description provided for @adminTotalSent.
  ///
  /// In es, this message translates to:
  /// **'Total enviados'**
  String get adminTotalSent;

  /// No description provided for @adminAvgDelivery.
  ///
  /// In es, this message translates to:
  /// **'Entrega prom.'**
  String get adminAvgDelivery;

  /// No description provided for @adminAvgOpen.
  ///
  /// In es, this message translates to:
  /// **'Apertura prom.'**
  String get adminAvgOpen;

  /// No description provided for @adminDailySends30.
  ///
  /// In es, this message translates to:
  /// **'Envíos diarios — últimos 30 días'**
  String get adminDailySends30;

  /// No description provided for @adminLegendSent.
  ///
  /// In es, this message translates to:
  /// **'Enviados'**
  String get adminLegendSent;

  /// No description provided for @adminLegendOpens.
  ///
  /// In es, this message translates to:
  /// **'Aperturas'**
  String get adminLegendOpens;

  /// No description provided for @adminNoSendData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos de envíos todavía.'**
  String get adminNoSendData;

  /// No description provided for @adminDevicesByPlatform.
  ///
  /// In es, this message translates to:
  /// **'Dispositivos por plataforma'**
  String get adminDevicesByPlatform;

  /// No description provided for @adminLatestNotifications.
  ///
  /// In es, this message translates to:
  /// **'Últimas notificaciones'**
  String get adminLatestNotifications;

  /// No description provided for @adminColNotification.
  ///
  /// In es, this message translates to:
  /// **'Notificación'**
  String get adminColNotification;

  /// No description provided for @adminColDelivery.
  ///
  /// In es, this message translates to:
  /// **'Entrega'**
  String get adminColDelivery;

  /// No description provided for @adminColOpen.
  ///
  /// In es, this message translates to:
  /// **'Apertura'**
  String get adminColOpen;

  /// No description provided for @adminPickDateTime.
  ///
  /// In es, this message translates to:
  /// **'Elige la fecha y hora de envío'**
  String get adminPickDateTime;

  /// No description provided for @adminScheduleNotification.
  ///
  /// In es, this message translates to:
  /// **'Programar notificación'**
  String get adminScheduleNotification;

  /// No description provided for @adminSendDateTime.
  ///
  /// In es, this message translates to:
  /// **'Fecha y hora de envío *'**
  String get adminSendDateTime;

  /// No description provided for @adminSelect.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar…'**
  String get adminSelect;

  /// No description provided for @adminRepetition.
  ///
  /// In es, this message translates to:
  /// **'Repetición'**
  String get adminRepetition;

  /// No description provided for @adminOnceOnly.
  ///
  /// In es, this message translates to:
  /// **'Una sola vez'**
  String get adminOnceOnly;

  /// No description provided for @adminDaily.
  ///
  /// In es, this message translates to:
  /// **'Diariamente'**
  String get adminDaily;

  /// No description provided for @adminWeekly.
  ///
  /// In es, this message translates to:
  /// **'Semanalmente'**
  String get adminWeekly;

  /// No description provided for @adminMonthly.
  ///
  /// In es, this message translates to:
  /// **'Mensualmente'**
  String get adminMonthly;

  /// No description provided for @adminDelivered.
  ///
  /// In es, this message translates to:
  /// **'entregados'**
  String get adminDelivered;

  /// No description provided for @adminFailed.
  ///
  /// In es, this message translates to:
  /// **'fallidos'**
  String get adminFailed;

  /// No description provided for @adminOpenStat.
  ///
  /// In es, this message translates to:
  /// **'apertura'**
  String get adminOpenStat;

  /// No description provided for @adminDeliveryStat.
  ///
  /// In es, this message translates to:
  /// **'entrega'**
  String get adminDeliveryStat;

  /// No description provided for @adminAdsPricesTitle.
  ///
  /// In es, this message translates to:
  /// **'Publicidad · Precios'**
  String get adminAdsPricesTitle;

  /// No description provided for @adminNoPriceData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos de precios'**
  String get adminNoPriceData;

  /// No description provided for @adminRunAdsSql.
  ///
  /// In es, this message translates to:
  /// **'Ejecuta el SQL de publicidad en Supabase primero.'**
  String get adminRunAdsSql;

  /// No description provided for @adminPricesByFormat.
  ///
  /// In es, this message translates to:
  /// **'Precios por formato'**
  String get adminPricesByFormat;

  /// No description provided for @adminUsersCount.
  ///
  /// In es, this message translates to:
  /// **'{count} usuarios'**
  String adminUsersCount(Object count);

  /// No description provided for @adminBillingUnitInfo.
  ///
  /// In es, this message translates to:
  /// **'La unidad de cobro (impresiones por precio) se calcula automáticamente según los usuarios activos: crece con la plataforma.'**
  String get adminBillingUnitInfo;

  /// No description provided for @adminMinCampaign.
  ///
  /// In es, this message translates to:
  /// **'Mín. campaña'**
  String get adminMinCampaign;

  /// No description provided for @adminInvalidPrice.
  ///
  /// In es, this message translates to:
  /// **'Precio inválido'**
  String get adminInvalidPrice;

  /// No description provided for @adminInvalidMinBudget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto mínimo inválido'**
  String get adminInvalidMinBudget;

  /// No description provided for @adminPricePerThousand.
  ///
  /// In es, this message translates to:
  /// **'Precio por 1 000 impresiones (MXN)'**
  String get adminPricePerThousand;

  /// No description provided for @adminPricePerSend.
  ///
  /// In es, this message translates to:
  /// **'Precio por envío (MXN)'**
  String get adminPricePerSend;

  /// No description provided for @adminFixedRate.
  ///
  /// In es, this message translates to:
  /// **'Tarifa fija (MXN)'**
  String get adminFixedRate;

  /// No description provided for @adminMinCampaignBudget.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto mínimo de campaña (MXN)'**
  String get adminMinCampaignBudget;

  /// No description provided for @adminSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get adminSave;

  /// No description provided for @adminCreditsTitle.
  ///
  /// In es, this message translates to:
  /// **'Créditos publicitarios'**
  String get adminCreditsTitle;

  /// No description provided for @adminSearchEstOwner.
  ///
  /// In es, this message translates to:
  /// **'Buscar establecimiento o dueño…'**
  String get adminSearchEstOwner;

  /// No description provided for @adminBalance.
  ///
  /// In es, this message translates to:
  /// **'saldo'**
  String get adminBalance;

  /// No description provided for @adminEnterValidAmount.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un monto válido'**
  String get adminEnterValidAmount;

  /// No description provided for @adminEnterDescription.
  ///
  /// In es, this message translates to:
  /// **'Escribe una descripción'**
  String get adminEnterDescription;

  /// No description provided for @adminCreditAdded.
  ///
  /// In es, this message translates to:
  /// **'Crédito agregado correctamente. Nuevo saldo: {balance}'**
  String adminCreditAdded(Object balance);

  /// No description provided for @adminCurrentBalance.
  ///
  /// In es, this message translates to:
  /// **'Saldo actual: {balance}'**
  String adminCurrentBalance(Object balance);

  /// No description provided for @adminAmountToAdd.
  ///
  /// In es, this message translates to:
  /// **'Monto a agregar (MXN)'**
  String get adminAmountToAdd;

  /// No description provided for @adminDescriptionReason.
  ///
  /// In es, this message translates to:
  /// **'Descripción / motivo'**
  String get adminDescriptionReason;

  /// No description provided for @adminSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando…'**
  String get adminSaving;

  /// No description provided for @adminAddCredit.
  ///
  /// In es, this message translates to:
  /// **'Agregar crédito'**
  String get adminAddCredit;

  /// No description provided for @adminBulkTitle.
  ///
  /// In es, this message translates to:
  /// **'Carga masiva superadmin'**
  String get adminBulkTitle;

  /// No description provided for @adminTabEstablishments.
  ///
  /// In es, this message translates to:
  /// **'Establecimientos'**
  String get adminTabEstablishments;

  /// No description provided for @adminTabPromotions.
  ///
  /// In es, this message translates to:
  /// **'Promociones'**
  String get adminTabPromotions;

  /// No description provided for @adminCsvEmpty.
  ///
  /// In es, this message translates to:
  /// **'El archivo CSV está vacío.'**
  String get adminCsvEmpty;

  /// No description provided for @adminSelectOwner.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un dueño antes de continuar.'**
  String get adminSelectOwner;

  /// No description provided for @adminUploadCsvRow.
  ///
  /// In es, this message translates to:
  /// **'Sube un CSV con al menos una fila de datos.'**
  String get adminUploadCsvRow;

  /// No description provided for @adminRowEmptyName.
  ///
  /// In es, this message translates to:
  /// **'Fila {row}: nombre vacío'**
  String adminRowEmptyName(Object row);

  /// No description provided for @adminRowInvalidDays.
  ///
  /// In es, this message translates to:
  /// **'Fila {row}: días inválidos (usa 1-7)'**
  String adminRowInvalidDays(Object row);

  /// No description provided for @adminRowError.
  ///
  /// In es, this message translates to:
  /// **'Fila {row}: {msg}'**
  String adminRowError(Object row, Object msg);

  /// No description provided for @adminEstCreated.
  ///
  /// In es, this message translates to:
  /// **'{count} establecimiento(s) creado(s)'**
  String adminEstCreated(Object count);

  /// No description provided for @adminPromosCreated.
  ///
  /// In es, this message translates to:
  /// **'{count} promoción(es) creada(s) · no cuentan contra el plan'**
  String adminPromosCreated(Object count);

  /// No description provided for @adminBulkEstBanner.
  ///
  /// In es, this message translates to:
  /// **'Crea establecimientos para cualquier dueño.\nEsta sesión: {count} creado(s).'**
  String adminBulkEstBanner(Object count);

  /// No description provided for @adminBulkPromoBanner.
  ///
  /// In es, this message translates to:
  /// **'Crea promociones para cualquier negocio. No cuentan contra el límite del plan.\nEsta sesión: {count} creada(s).'**
  String adminBulkPromoBanner(Object count);

  /// No description provided for @adminTemplateEstSubject.
  ///
  /// In es, this message translates to:
  /// **'Plantilla establecimientos Promofy'**
  String get adminTemplateEstSubject;

  /// No description provided for @adminTemplatePromoSubject.
  ///
  /// In es, this message translates to:
  /// **'Plantilla promociones Promofy'**
  String get adminTemplatePromoSubject;

  /// No description provided for @adminDownloadCsvTemplate.
  ///
  /// In es, this message translates to:
  /// **'Descargar plantilla CSV'**
  String get adminDownloadCsvTemplate;

  /// No description provided for @adminOwnerRequired.
  ///
  /// In es, this message translates to:
  /// **'Dueño *'**
  String get adminOwnerRequired;

  /// No description provided for @adminSelectOwnerHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un dueño…'**
  String get adminSelectOwnerHint;

  /// No description provided for @adminSelectCsvFile.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar archivo CSV'**
  String get adminSelectCsvFile;

  /// No description provided for @adminPreviewRows.
  ///
  /// In es, this message translates to:
  /// **'Vista previa ({count} fila(s)):'**
  String adminPreviewRows(Object count);

  /// No description provided for @adminCreatingEsts.
  ///
  /// In es, this message translates to:
  /// **'Creando establecimientos…'**
  String get adminCreatingEsts;

  /// No description provided for @adminCreateEstsBtn.
  ///
  /// In es, this message translates to:
  /// **'Crear {count} establecimiento(s)'**
  String adminCreateEstsBtn(Object count);

  /// No description provided for @adminSelectEst.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un establecimiento.'**
  String get adminSelectEst;

  /// No description provided for @adminEstRequired.
  ///
  /// In es, this message translates to:
  /// **'Establecimiento *'**
  String get adminEstRequired;

  /// No description provided for @adminSelectBusinessHint.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un negocio…'**
  String get adminSelectBusinessHint;

  /// No description provided for @adminCreatingPromos.
  ///
  /// In es, this message translates to:
  /// **'Creando promociones…'**
  String get adminCreatingPromos;

  /// No description provided for @adminCreatePromosBtn.
  ///
  /// In es, this message translates to:
  /// **'Crear {count} promoción(es)'**
  String adminCreatePromosBtn(Object count);

  /// No description provided for @logrosTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Logros'**
  String get logrosTitle;

  /// No description provided for @logrosLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar tus logros.'**
  String get logrosLoadError;

  /// No description provided for @logrosRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get logrosRetry;

  /// No description provided for @logrosSectionVisits.
  ///
  /// In es, this message translates to:
  /// **'Insignias de visitas'**
  String get logrosSectionVisits;

  /// No description provided for @logrosSectionStreaks.
  ///
  /// In es, this message translates to:
  /// **'Rachas semanales'**
  String get logrosSectionStreaks;

  /// No description provided for @logrosNextLevel.
  ///
  /// In es, this message translates to:
  /// **'Próximo nivel: {label}'**
  String logrosNextLevel(Object label);

  /// No description provided for @logrosAnnualVisits.
  ///
  /// In es, this message translates to:
  /// **'{count} visitas anuales'**
  String logrosAnnualVisits(Object count);

  /// No description provided for @logrosConsecutiveWeeks.
  ///
  /// In es, this message translates to:
  /// **'{count} semanas consecutivas'**
  String logrosConsecutiveWeeks(Object count);

  /// No description provided for @logrosVisitsToGo.
  ///
  /// In es, this message translates to:
  /// **'{count} visitas más para alcanzarlo'**
  String logrosVisitsToGo(Object count);

  /// No description provided for @logrosStreakDescEnRacha.
  ///
  /// In es, this message translates to:
  /// **'Visitaste negocios 3 semanas seguidas'**
  String get logrosStreakDescEnRacha;

  /// No description provided for @logrosStreakDescImparable.
  ///
  /// In es, this message translates to:
  /// **'8 semanas sin parar — eres imparable'**
  String get logrosStreakDescImparable;

  /// No description provided for @logrosStreakDescLeyenda.
  ///
  /// In es, this message translates to:
  /// **'26 semanas (medio año) de racha perfecta'**
  String get logrosStreakDescLeyenda;

  /// No description provided for @filterSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtros'**
  String get filterSheetTitle;

  /// No description provided for @filterSheetClearAll.
  ///
  /// In es, this message translates to:
  /// **'Limpiar todo'**
  String get filterSheetClearAll;

  /// No description provided for @filterSheetSectionPlaceFeatures.
  ///
  /// In es, this message translates to:
  /// **'Características del lugar'**
  String get filterSheetSectionPlaceFeatures;

  /// No description provided for @filterSheetSectionCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get filterSheetSectionCategory;

  /// No description provided for @filterSheetSectionFoodType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de comida'**
  String get filterSheetSectionFoodType;

  /// No description provided for @filterSheetSectionDay.
  ///
  /// In es, this message translates to:
  /// **'Día'**
  String get filterSheetSectionDay;

  /// No description provided for @filterSheetSectionPaymentMethod.
  ///
  /// In es, this message translates to:
  /// **'Método de pago'**
  String get filterSheetSectionPaymentMethod;

  /// No description provided for @filterSheetApply.
  ///
  /// In es, this message translates to:
  /// **'Aplicar filtros'**
  String get filterSheetApply;

  /// No description provided for @filterSheetApplyWithCount.
  ///
  /// In es, this message translates to:
  /// **'Aplicar ({count} {count, plural, one {filtro} other {filtros}})'**
  String filterSheetApplyWithCount(num count);

  /// No description provided for @filterChipsActiveNow.
  ///
  /// In es, this message translates to:
  /// **'Activas ahora'**
  String get filterChipsActiveNow;

  /// No description provided for @filterChipsFlash.
  ///
  /// In es, this message translates to:
  /// **'⚡ Relámpago'**
  String get filterChipsFlash;

  /// No description provided for @filterChipsFavorites.
  ///
  /// In es, this message translates to:
  /// **'⭐ Mis favoritas'**
  String get filterChipsFavorites;

  /// No description provided for @filterChipsBirthday.
  ///
  /// In es, this message translates to:
  /// **'🎂 Cumpleañero'**
  String get filterChipsBirthday;

  /// No description provided for @filterChipsAdvancedMore.
  ///
  /// In es, this message translates to:
  /// **'Más filtros'**
  String get filterChipsAdvancedMore;

  /// No description provided for @filterChipsAdvancedCount.
  ///
  /// In es, this message translates to:
  /// **'Filtros ({count})'**
  String filterChipsAdvancedCount(Object count);

  /// No description provided for @adSplashAdLabel.
  ///
  /// In es, this message translates to:
  /// **'Publicidad'**
  String get adSplashAdLabel;

  /// No description provided for @adSplashPromoSpecial.
  ///
  /// In es, this message translates to:
  /// **'Promoción especial de {name}'**
  String adSplashPromoSpecial(Object name);

  /// No description provided for @adSplashDiscoverMsg.
  ///
  /// In es, this message translates to:
  /// **'Toca para descubrir sus promociones exclusivas'**
  String get adSplashDiscoverMsg;

  /// No description provided for @adSplashViewPromos.
  ///
  /// In es, this message translates to:
  /// **'Ver promociones'**
  String get adSplashViewPromos;

  /// No description provided for @sponsoredCardBadge.
  ///
  /// In es, this message translates to:
  /// **'Patrocinado'**
  String get sponsoredCardBadge;

  /// No description provided for @sponsoredCardSeePromotions.
  ///
  /// In es, this message translates to:
  /// **'Ver sus promociones'**
  String get sponsoredCardSeePromotions;

  /// No description provided for @sponsoredCardAd.
  ///
  /// In es, this message translates to:
  /// **'Anuncio'**
  String get sponsoredCardAd;

  /// No description provided for @adBannerSeePromotions.
  ///
  /// In es, this message translates to:
  /// **'Ver sus promociones'**
  String get adBannerSeePromotions;

  /// No description provided for @adBannerAdLabel.
  ///
  /// In es, this message translates to:
  /// **'Publicidad'**
  String get adBannerAdLabel;

  /// No description provided for @paymentResultGoHome.
  ///
  /// In es, this message translates to:
  /// **'Ir al inicio'**
  String get paymentResultGoHome;

  /// No description provided for @paymentResultTryAgain.
  ///
  /// In es, this message translates to:
  /// **'Intentar de nuevo'**
  String get paymentResultTryAgain;

  /// No description provided for @paymentResultSuccessTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Pago exitoso!'**
  String get paymentResultSuccessTitle;

  /// No description provided for @paymentResultSuccessSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu saldo de créditos publicitarios se verá\nreflejado en tu panel en unos momentos.'**
  String get paymentResultSuccessSubtitle;

  /// No description provided for @paymentResultFailureTitle.
  ///
  /// In es, this message translates to:
  /// **'Pago no completado'**
  String get paymentResultFailureTitle;

  /// No description provided for @paymentResultFailureSubtitle.
  ///
  /// In es, this message translates to:
  /// **'No se realizó ningún cargo. Puedes\nintentar de nuevo cuando quieras.'**
  String get paymentResultFailureSubtitle;

  /// No description provided for @paymentResultPendingTitle.
  ///
  /// In es, this message translates to:
  /// **'Pago en proceso'**
  String get paymentResultPendingTitle;

  /// No description provided for @paymentResultPendingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu pago está siendo procesado.\nTe notificaremos cuando se confirme.'**
  String get paymentResultPendingSubtitle;

  /// No description provided for @paymentResultSubscriptionTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Suscripción activada!'**
  String get paymentResultSubscriptionTitle;

  /// No description provided for @paymentResultSubscriptionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu plan Promofy ya está activo.\nDisfruta todas las funciones de tu negocio.'**
  String get paymentResultSubscriptionSubtitle;

  /// No description provided for @locationPermTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Las promos te esperan\ncerca de ti!'**
  String get locationPermTitle;

  /// No description provided for @locationPermSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Comparte tu ubicación para ver\nlas mejores promociones ordenadas\npor distancia al instante.'**
  String get locationPermSubtitle;

  /// No description provided for @locationPermAllowButton.
  ///
  /// In es, this message translates to:
  /// **'Permitir ubicación'**
  String get locationPermAllowButton;

  /// No description provided for @locationPermSkipButton.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get locationPermSkipButton;

  /// No description provided for @splashScrTagline.
  ///
  /// In es, this message translates to:
  /// **'Descubre promociones cerca de ti'**
  String get splashScrTagline;

  /// No description provided for @settingsMyFavs.
  ///
  /// In es, this message translates to:
  /// **'Mis favs'**
  String get settingsMyFavs;

  /// No description provided for @tourSkip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get tourSkip;

  /// No description provided for @tourNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get tourNext;

  /// No description provided for @tourStart.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get tourStart;

  /// No description provided for @tourReplay.
  ///
  /// In es, this message translates to:
  /// **'Ver tutorial'**
  String get tourReplay;

  /// No description provided for @tour1Title.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido a Promofy!'**
  String get tour1Title;

  /// No description provided for @tour1Desc.
  ///
  /// In es, this message translates to:
  /// **'Descubre las mejores promociones de restaurantes y entretenimiento cerca de ti.'**
  String get tour1Desc;

  /// No description provided for @tour2Title.
  ///
  /// In es, this message translates to:
  /// **'Explora cerca de ti'**
  String get tour2Title;

  /// No description provided for @tour2Desc.
  ///
  /// In es, this message translates to:
  /// **'En Inicio y Lugares encuentras promos y negocios ordenados por distancia. Usa los filtros para hallar justo lo que se te antoja.'**
  String get tour2Desc;

  /// No description provided for @tour3Title.
  ///
  /// In es, this message translates to:
  /// **'Promos Relámpago'**
  String get tour3Title;

  /// No description provided for @tour3Desc.
  ///
  /// In es, this message translates to:
  /// **'Ofertas por tiempo limitado. ¡Aprovéchalas antes de que se acaben!'**
  String get tour3Desc;

  /// No description provided for @tour4Title.
  ///
  /// In es, this message translates to:
  /// **'Sellos de lealtad'**
  String get tour4Title;

  /// No description provided for @tour4Desc.
  ///
  /// In es, this message translates to:
  /// **'Muestra tu código QR en cada visita, junta sellos y gana recompensas en tus lugares favoritos.'**
  String get tour4Desc;

  /// No description provided for @tour5Title.
  ///
  /// In es, this message translates to:
  /// **'Favoritos y cumpleaños'**
  String get tour5Title;

  /// No description provided for @tour5Desc.
  ///
  /// In es, this message translates to:
  /// **'Guarda tus promos favoritas con el corazón y recibe un regalo especial en tu cumpleaños.'**
  String get tour5Desc;

  /// No description provided for @ownerTour1Title.
  ///
  /// In es, this message translates to:
  /// **'¡Ya eres negocio Promofy!'**
  String get ownerTour1Title;

  /// No description provided for @ownerTour1Desc.
  ///
  /// In es, this message translates to:
  /// **'Administra todo desde la pestaña «Mi negocio»: tus locales, promociones, publicidad y estadísticas.'**
  String get ownerTour1Desc;

  /// No description provided for @ownerTour2Title.
  ///
  /// In es, this message translates to:
  /// **'Crea promociones'**
  String get ownerTour2Title;

  /// No description provided for @ownerTour2Desc.
  ///
  /// In es, this message translates to:
  /// **'Publica promos normales, flash (relámpago) y de cumpleañero, y arma tu programa de sellos de lealtad.'**
  String get ownerTour2Desc;

  /// No description provided for @ownerTour3Title.
  ///
  /// In es, this message translates to:
  /// **'Valida canjes con QR'**
  String get ownerTour3Title;

  /// No description provided for @ownerTour3Desc.
  ///
  /// In es, this message translates to:
  /// **'Escanea el código del cliente para validar sus promociones y registrar sus visitas de lealtad.'**
  String get ownerTour3Desc;

  /// No description provided for @ownerTour4Title.
  ///
  /// In es, this message translates to:
  /// **'Atrae más clientes'**
  String get ownerTour4Title;

  /// No description provided for @ownerTour4Desc.
  ///
  /// In es, this message translates to:
  /// **'Crea campañas de publicidad (splash, banner, destacada y notificaciones) para llegar a más gente cerca de ti.'**
  String get ownerTour4Desc;

  /// No description provided for @ownerTour5Title.
  ///
  /// In es, this message translates to:
  /// **'Mide y crece'**
  String get ownerTour5Title;

  /// No description provided for @ownerTour5Desc.
  ///
  /// In es, this message translates to:
  /// **'Revisa tus estadísticas y ticket promedio, y administra tu plan y complementos cuando lo necesites.'**
  String get ownerTour5Desc;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
