import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get languageAuto => 'Automático (del dispositivo)';

  @override
  String get retry => 'Reintentar';

  @override
  String get explore => 'Explorar';

  @override
  String get favTitle => 'Mis favoritos';

  @override
  String get favTabPromos => 'Promociones';

  @override
  String get favTabEstablishments => 'Establecimientos';

  @override
  String get favEmptyPromosTitle => 'Aún no tienes promos favoritas';

  @override
  String get favEmptyPromosSubtitle => 'Toca el corazón en cualquier promo\npara guardarla aquí';

  @override
  String get favEmptyEstTitle => 'Aún no tienes negocios favoritos';

  @override
  String get favEmptyEstSubtitle => 'Entra a un negocio y toca el corazón\npara guardarlo aquí';

  @override
  String get removeFromFavorites => 'Quitar de favoritos';

  @override
  String get loginWelcome => 'Bienvenido a Promofy';

  @override
  String get loginSubtitle => 'Descubre promociones cerca de ti';

  @override
  String get loginContinueGoogle => 'Continuar con Google';

  @override
  String get loginOr => 'o';

  @override
  String get loginEmailLabel => 'Correo electrónico';

  @override
  String get loginEmailEmpty => 'Ingresa tu correo';

  @override
  String get loginEmailInvalid => 'Correo no válido';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginPasswordEmpty => 'Ingresa tu contraseña';

  @override
  String get loginPasswordMinLength => 'Mínimo 6 caracteres';

  @override
  String get loginReferralLabel => 'Código de invitación (opcional)';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginSignInButton => 'Iniciar sesión';

  @override
  String get loginSignUpButton => 'Crear cuenta';

  @override
  String get loginNoAccount => '¿No tienes cuenta? ';

  @override
  String get loginHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get loginSignUpLink => 'Regístrate';

  @override
  String get loginSignInLink => 'Inicia sesión';

  @override
  String get loginGuestButton => 'Explorar sin cuenta';

  @override
  String get loginResetInvalidEmail => 'Ingresa un correo válido.';

  @override
  String get loginResetTitle => 'Recuperar contraseña';

  @override
  String get loginResetDone => 'Listo';

  @override
  String get loginResetCancel => 'Cancelar';

  @override
  String get loginResetSend => 'Enviar';

  @override
  String get loginResetDescription => 'Te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get loginResetEmailHint => 'tu@correo.com';

  @override
  String get loginResetSuccessTitle => '¡Correo enviado!';

  @override
  String get loginResetSuccessBody => 'Revisa tu bandeja de entrada y sigue las instrucciones.';

  @override
  String get loginResetSpamHint => 'Si no llega en unos minutos, revisa la carpeta de spam.';

  @override
  String get onboardingTitle => 'Completa tu perfil';

  @override
  String get onboardingExit => 'Salir';

  @override
  String get onboardingHeading => 'Cuéntanos sobre ti';

  @override
  String get onboardingAdultOnlyNotice => 'Promofy es exclusivo para mayores de 18 años';

  @override
  String get onboardingNameQuestion => '¿Cuál es tu nombre?';

  @override
  String get onboardingNameHint => 'Tu nombre completo';

  @override
  String get onboardingNameRequired => 'Ingresa tu nombre';

  @override
  String get onboardingBirthQuestion => '¿Cuándo naciste?';

  @override
  String get onboardingSelectBirthDate => 'Selecciona tu fecha de nacimiento';

  @override
  String get onboardingGenderQuestion => '¿Cuál es tu sexo?';

  @override
  String get onboardingGenderMale => 'Masculino';

  @override
  String get onboardingGenderFemale => 'Femenino';

  @override
  String get onboardingGenderPreferNot => 'Prefiero no decir';

  @override
  String get onboardingSubmit => 'Completar mi perfil';

  @override
  String get onboardingMustBeAdult => 'Debes ser mayor de 18 años';

  @override
  String get onboardingConfirm => 'Confirmar';

  @override
  String get onboardingCancel => 'Cancelar';

  @override
  String get onboardingMustBeAdultToUse => 'Debes ser mayor de 18 años para usar Promofy';

  @override
  String get onboardingSelectGender => 'Selecciona tu género';

  @override
  String get resetPwdAppBarTitle => 'Nueva contraseña';

  @override
  String get resetPwdUpdateError => 'No se pudo actualizar la contraseña.';

  @override
  String get resetPwdSuccessTitle => '¡Contraseña actualizada!';

  @override
  String get resetPwdSuccessSubtitle => 'Ya puedes iniciar sesión\ncon tu nueva contraseña.';

  @override
  String get resetPwdGoHome => 'Ir al inicio';

  @override
  String get resetPwdFormTitle => 'Crea tu nueva contraseña';

  @override
  String get resetPwdFormHint => 'Debe tener al menos 6 caracteres.';

  @override
  String get resetPwdNewLabel => 'Nueva contraseña';

  @override
  String get resetPwdMinLength => 'Mínimo 6 caracteres';

  @override
  String get resetPwdConfirmLabel => 'Confirmar contraseña';

  @override
  String get resetPwdMismatch => 'Las contraseñas no coinciden';

  @override
  String get resetPwdSave => 'Guardar contraseña';

  @override
  String get homeSearchHint => 'Buscar promo o restaurante...';

  @override
  String homeEmptySearch(Object query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get homeEmptyFilters => 'Sin resultados para estos filtros';

  @override
  String get homeEmptyNoPromos => 'No hay promociones por aquí aún';

  @override
  String get homeClearSearchAndFilters => 'Limpiar búsqueda y filtros';

  @override
  String get homeRetry => 'Reintentar';

  @override
  String get promoDetailNew => 'Nuevo';

  @override
  String get promoDetailBirthdayGift => 'Tu regalo de cumpleaños';

  @override
  String promoDetailConditions(Object terms) {
    return 'Condiciones: $terms';
  }

  @override
  String get promoDetailDescription => 'Descripción';

  @override
  String get promoDetailAvailability => 'Disponibilidad';

  @override
  String get promoDetailShare => 'Compartir';

  @override
  String get promoDetailSaved => 'Guardado';

  @override
  String get promoDetailSave => 'Guardar';

  @override
  String get promoDetailFlash => '⚡ Relámpago';

  @override
  String promoDetailFlashEndsInHours(Object hours, Object minutes) {
    return '⚡ Termina en ${hours}h ${minutes}m';
  }

  @override
  String promoDetailFlashEndsInMinutes(Object minutes) {
    return '⚡ Termina en ${minutes}m';
  }

  @override
  String get restaurantNew => 'Nuevo';

  @override
  String get restaurantTypeUrbanMobile => 'Urbano / Móvil';

  @override
  String get restaurantTypeLocal => 'Local';

  @override
  String get restaurantCall => 'Llamar';

  @override
  String get restaurantWebsite => 'Web';

  @override
  String get restaurantCharacteristics => 'Características';

  @override
  String get restaurantPaymentMethods => 'Métodos de pago';

  @override
  String get restaurantSchedule => 'Horario';

  @override
  String get restaurantClosed => 'Cerrado';

  @override
  String get restaurantLocation => 'Ubicación';

  @override
  String get restaurantViewOnMap => 'Ver en mapa';

  @override
  String get restaurantGetDirections => 'Cómo llegar';

  @override
  String get restaurantPhotos => 'Fotos';

  @override
  String get restaurantLoyaltyProgram => 'Programa de lealtad';

  @override
  String restaurantVisitsCount(Object count) {
    return '$count visitas';
  }

  @override
  String restaurantValidUntil(Object date, Object days) {
    return 'Vigente hasta $date · $days días';
  }

  @override
  String restaurantEnded(Object date) {
    return 'Terminó $date';
  }

  @override
  String get restaurantViewStampsAndQr => 'Ver mis sellos y QR';

  @override
  String get restaurantActivePromos => 'Promociones activas';

  @override
  String get restaurantNoActivePromos => 'Sin promociones activas por ahora.';

  @override
  String get restaurantNoPromosToday => 'Sin promociones para hoy.';

  @override
  String get restaurantAlsoThisWeek => 'También esta semana';

  @override
  String get restaurantFlash => 'Flash';

  @override
  String get restaurantRetry => 'Reintentar';

  @override
  String get lugaresSearchHint => 'Buscar negocio...';

  @override
  String get lugaresChipOpenNow => 'Abiertos ahora';

  @override
  String get lugaresChipFlash => '⚡ Relámpago';

  @override
  String get lugaresChipFavorites => '⭐ Mis favoritos';

  @override
  String get lugaresChipMoreFilters => 'Más filtros';

  @override
  String lugaresChipFiltersCount(Object count) {
    return 'Filtros ($count)';
  }

  @override
  String get lugaresFiltersTitle => 'Filtros';

  @override
  String get lugaresClearAll => 'Limpiar todo';

  @override
  String get lugaresSectionCharacteristics => 'Características del lugar';

  @override
  String get lugaresSectionCategory => 'Categoría';

  @override
  String get lugaresSectionDay => 'Día';

  @override
  String get lugaresSectionPayment => 'Método de pago';

  @override
  String get lugaresDayMon => 'Lun';

  @override
  String get lugaresDayTue => 'Mar';

  @override
  String get lugaresDayWed => 'Mié';

  @override
  String get lugaresDayThu => 'Jue';

  @override
  String get lugaresDayFri => 'Vie';

  @override
  String get lugaresDaySat => 'Sáb';

  @override
  String get lugaresDaySun => 'Dom';

  @override
  String get lugaresPaymentCash => 'Efectivo';

  @override
  String get lugaresPaymentCard => 'Tarjeta';

  @override
  String get lugaresPaymentTransfer => 'Transferencia';

  @override
  String get lugaresPaymentMercadopago => 'MercadoPago';

  @override
  String lugaresApplyWithCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'filtros',
      one: 'filtro',
    );
    return 'Aplicar ($count $_temp0)';
  }

  @override
  String get lugaresApplyFilters => 'Aplicar filtros';

  @override
  String get lugaresEmptyFiltered => 'Sin resultados para los filtros aplicados';

  @override
  String get lugaresEmptyNoNearby => 'No hay negocios cerca por ahora';

  @override
  String get lugaresClearFilters => 'Limpiar filtros';

  @override
  String get lugaresRetry => 'Reintentar';

  @override
  String get stampsTitle => 'Mis Sellos';

  @override
  String get stampsMyQrTooltip => 'Mi QR de visitas';

  @override
  String get stampsSectionReady => 'Recompensas listas para canjear';

  @override
  String get stampsSectionInProgress => 'En progreso';

  @override
  String get stampsSuffixProgram => 'programa';

  @override
  String get stampsSuffixPrograms => 'programas';

  @override
  String get stampsSectionEarned => 'Recompensas ganadas';

  @override
  String get stampsSuffixTotal => 'totales';

  @override
  String get stampsSeeAllRewards => 'Ver todas las recompensas →';

  @override
  String get stampsTapForRedemptionQr => 'Toca para ver QR de canje';

  @override
  String get stampsReadyBadge => '¡LISTA!';

  @override
  String get stampsFinished => 'Terminado';

  @override
  String stampsVisitsCount(Object visits, Object required) {
    return '$visits/$required visitas';
  }

  @override
  String stampsStampsLeft(Object count) {
    return '¡Te faltan $count! 🔥';
  }

  @override
  String stampsExpiredOn(Object date) {
    return 'Venció el $date';
  }

  @override
  String stampsExpiresOn(Object date) {
    return 'Caduca el $date';
  }

  @override
  String get stampsRedeemed => 'Canjeada';

  @override
  String get stampsRedeemReward => 'Canjear recompensa';

  @override
  String stampsAtEstablishment(Object name) {
    return 'en $name';
  }

  @override
  String stampsCodeLabel(Object code) {
    return 'Código: $code';
  }

  @override
  String get stampsShowCodeToStaff => 'Muestra este código al personal';

  @override
  String get stampsStaffWillScan => 'Lo escanearán para validar tu recompensa';

  @override
  String get stampsMyQrTitle => 'Mi código QR';

  @override
  String get stampsMyQrSubtitle => 'Muéstrale este código al negocio para registrar tu visita.';

  @override
  String get stampsUniqueAccountCode => 'Código único de tu cuenta';

  @override
  String get stampsRetry => 'Reintentar';

  @override
  String get stampsEmptyTitle => 'Aún no tienes sellos';

  @override
  String get stampsEmptyMsg => 'Visita negocios con programa de lealtad y muéstrales tu código QR para acumular sellos.';

  @override
  String get stampsViewMyQr => 'Ver mi QR';

  @override
  String get loyaltyTitle => 'Programa de lealtad';

  @override
  String get loyaltyScan => 'Escanear';

  @override
  String get loyaltyStatusDeactivated => 'Desactivado';

  @override
  String loyaltyStatusExpired(Object date) {
    return 'Venció el $date';
  }

  @override
  String loyaltyStatusExpiresIn(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Vence en $days días',
      one: 'Vence en $days día',
    );
    return '$_temp0';
  }

  @override
  String loyaltyStatusActive(Object date) {
    return 'Activo — termina $date';
  }

  @override
  String get loyaltyVisitsRequired => 'Visitas requeridas';

  @override
  String get loyaltyReward => 'Premio';

  @override
  String get loyaltyStart => 'Inicio';

  @override
  String get loyaltyEnd => 'Fin';

  @override
  String get loyaltyEndNow => 'Terminar programa ahora';

  @override
  String get loyaltyCreateNew => 'Crear nuevo programa';

  @override
  String get loyaltyEndDialogTitle => '¿Terminar programa?';

  @override
  String get loyaltyEndDialogContent => 'Todos los clientes dejarán de acumular visitas en este programa. Podrás crear uno nuevo cuando quieras.';

  @override
  String get loyaltyCancel => 'Cancelar';

  @override
  String get loyaltyEnd2 => 'Terminar';

  @override
  String get loyaltyNoProgramDesc => 'Fideliza a tus clientes con un sistema de sellos digital. Define cuántas visitas necesitan para ganar su premio.';

  @override
  String get loyaltyCreate => 'Crear programa';

  @override
  String get loyaltyParticipants => 'Participantes';

  @override
  String get loyaltyRewardWon => 'Premio ganado';

  @override
  String get loyaltyViewClients => 'Ver clientes';

  @override
  String get loyaltyClientsTitle => 'Mis clientes';

  @override
  String get loyaltyClientsLoadError => 'No se pudieron cargar los clientes.';

  @override
  String get loyaltyClientsRetry => 'Reintentar';

  @override
  String get loyaltyClientsCurrentProgram => 'PROGRAMA ACTUAL';

  @override
  String loyaltyClientsParticipants(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes',
      one: '$count participante',
    );
    return '$_temp0';
  }

  @override
  String get loyaltyClientsEmptyProgram => 'Aún no hay clientes en este programa. Escanea el QR de tus primeros visitantes.';

  @override
  String get loyaltyClientsReward => '¡Premio!';

  @override
  String loyaltyClientsStampsLeft(Object count) {
    return '$count para su premio';
  }

  @override
  String get loyaltyClientsHistoryHeader => 'HISTORIAL DE COMENSALES';

  @override
  String get loyaltyClientsHistorySubtitle => 'Total de visitas registradas con QR, de mayor a menor.';

  @override
  String get loyaltyClientsEmptyHistory => 'El historial aparecerá aquí conforme escanees a tus clientes con QR.';

  @override
  String get loyaltyClientsColumnClient => 'Cliente';

  @override
  String get loyaltyClientsColumnVisits => 'Visitas';

  @override
  String get loyaltyClientsColumnSpent => 'Gasto';

  @override
  String get loyaltyClientsColumnLast => 'Última';

  @override
  String get qrInvalidCode => 'QR no válido. Pide al cliente que muestre su código.';

  @override
  String get qrScanTitle => 'Escanear cliente';

  @override
  String get qrTorch => 'Linterna';

  @override
  String get qrPointInstruction => 'Apunta al QR del cliente';

  @override
  String get qrErrorUnauthorized => 'No tienes permiso para registrar visitas en este programa.';

  @override
  String get qrErrorProgramInactive => 'El programa está inactivo o venció.';

  @override
  String get qrErrorNetwork => 'Error de conexión. Intenta de nuevo.';

  @override
  String get qrErrorUnexpected => 'Ocurrió un error inesperado.';

  @override
  String get qrErrorMinTicket => 'El consumo no alcanza el mínimo del programa.';

  @override
  String get qrErrorAlreadyToday => 'Este cliente ya registró un sello hoy.';

  @override
  String get qrErrorTooSoon => 'Aún no puede registrar otro sello. Intenta más tarde.';

  @override
  String get qrErrorRewardExpired => 'La recompensa ya venció.';

  @override
  String get qrTicketAmountTitle => 'Monto del consumo';

  @override
  String get qrTicketCancel => 'Cancelar';

  @override
  String get qrTicketConfirm => 'Registrar';

  @override
  String qrMinTicketHint(Object amount) {
    return 'Consumo mínimo para sellar: \$$amount';
  }

  @override
  String qrMinTicketError(Object amount) {
    return 'El consumo debe ser de al menos \$$amount.';
  }

  @override
  String get loyaltyRulesTitle => 'Reglas (opcional)';

  @override
  String get loyaltyRulesSubtitle => 'Activa solo las que necesites. Deja en blanco o 0 para desactivar una regla.';

  @override
  String get loyaltyRuleOnePerDay => 'Máximo 1 sello por día por cliente';

  @override
  String get loyaltyRuleMinTicket => 'Consumo mínimo para sellar';

  @override
  String get loyaltyRuleMinHours => 'Tiempo mínimo entre sellos';

  @override
  String get loyaltyRuleStampValidity => 'Vigencia de los sellos en curso';

  @override
  String get loyaltyRuleRewardValidity => 'Vigencia de la recompensa';

  @override
  String get loyaltyRuleOffHint => '0 = sin límite';

  @override
  String get loyaltyRuleHoursSuffix => 'horas';

  @override
  String get loyaltyRuleDaysSuffix => 'días';

  @override
  String get qrCouldNotRegister => 'No se pudo registrar';

  @override
  String get qrRewardWonTitle => '¡Premio ganado! 🎉';

  @override
  String qrRewardWonMessage(Object visits) {
    return 'El cliente completó $visits visitas. ¡Es momento de entregarle su regalo!';
  }

  @override
  String get qrVisitRegistered => 'Visita registrada';

  @override
  String qrVisitsLeft(Object count) {
    return 'Al cliente le faltan $count visita(s) para su premio.';
  }

  @override
  String get qrProgramCompleted => '¡Completó el programa!';

  @override
  String get qrBillAmountLabel => 'Importe de la cuenta (opcional)';

  @override
  String get qrBillAmountHint => 'Ej. 350';

  @override
  String get qrBillAmountHelper => 'Registra cuánto gastó el cliente para medir el ROI de Promofy.';

  @override
  String get qrDone => 'Listo';

  @override
  String qrVisitsCount(Object current, Object total) {
    return '$current/$total visitas';
  }

  @override
  String get loyaltyFormTitle => 'Nuevo programa de lealtad';

  @override
  String get loyaltyFormInfo => 'El cliente muestra su QR, tú lo escaneas en cada visita. Al completar el número de visitas, recibirá su premio. Cuando el programa termine puedes crear uno nuevo y todos los contadores se reinician.';

  @override
  String get loyaltyFormVisitsLabel => 'Visitas para ganar el premio';

  @override
  String get loyaltyFormVisitsHint => 'Ej. 5';

  @override
  String get loyaltyFormVisitsSuffix => 'visitas';

  @override
  String get loyaltyFormVisitsMin => 'Mínimo 2 visitas';

  @override
  String get loyaltyFormVisitsMax => 'Máximo 50 visitas';

  @override
  String get loyaltyFormRewardLabel => '¿Qué gana el cliente?';

  @override
  String get loyaltyFormRewardHint => 'Ej. Café gratis, 20% de descuento, postre gratis…';

  @override
  String get loyaltyFormRewardRequired => 'Describe el premio';

  @override
  String get loyaltyFormValidityLabel => 'Vigencia del programa';

  @override
  String get loyaltyFormStartLabel => 'Inicio';

  @override
  String get loyaltyFormEndLabel => 'Fin';

  @override
  String get loyaltyFormSelectDate => 'Seleccionar';

  @override
  String get loyaltyFormSaving => 'Guardando…';

  @override
  String get loyaltyFormSubmit => 'Activar programa';

  @override
  String get loyaltyFormSelectEndDate => 'Selecciona la fecha de fin del programa.';

  @override
  String get loyaltyFormCreateError => 'Error al crear el programa. Intenta de nuevo.';

  @override
  String get plansWebviewSubscriptionTitle => 'Suscripción Promofy';

  @override
  String get plansWebviewAddonTitle => 'Comprar add-on';

  @override
  String get plansAppBarTitle => 'Planes y pagos';

  @override
  String get plansRetry => 'Reintentar';

  @override
  String get plansPaymentApprovedTitle => '¡Pago aprobado!';

  @override
  String get plansPaymentPendingTitle => 'Pago en proceso';

  @override
  String get plansPaymentApprovedBody => 'Tu suscripción fue activada correctamente. Ya puedes disfrutar de todos los beneficios de tu plan.';

  @override
  String get plansPaymentPendingBody => 'Tu pago está siendo procesado. En cuanto se confirme, tu plan se actualizará automáticamente.';

  @override
  String get plansGotIt => 'Entendido';

  @override
  String get plansLaunchPromoTitle => 'Promoción de Lanzamiento';

  @override
  String get plansLaunchPromoSubtitle => 'Desde \$99 MXN. Lo que vale el plan lo recibes en créditos de publicidad.';

  @override
  String get plansLaunchPromoValidUntil => 'Válido hasta el 18 de julio de 2026';

  @override
  String get plansActivePlanFallback => 'Plan activo';

  @override
  String get plansNoActivePlan => 'Sin plan activo';

  @override
  String get plansCurrentPlanLabel => 'Tu plan actual';

  @override
  String get plansActiveBadge => 'Activo';

  @override
  String get plansCurrentBadge => 'Actual';

  @override
  String plansPricePerMonth(Object amount) {
    return '\$$amount MXN/mes';
  }

  @override
  String get plansFree => 'Gratis';

  @override
  String get plansMxnPerMonthSuffix => ' MXN/mes';

  @override
  String plansAdCredit(Object amount) {
    return '+\$$amount en publicidad';
  }

  @override
  String plansFeatureEstablishments(Object count) {
    return '$count establecimiento(s)';
  }

  @override
  String plansFeaturePromotions(Object count) {
    return '$count promociones normales activas';
  }

  @override
  String get plansFeatureFlashSingle => '1 promo flash al mes';

  @override
  String get plansFeatureFlashMulti => '1 promo flash/mes por establecimiento';

  @override
  String get plansFeatureBirthdaySingle => 'Promo cumpleañero';

  @override
  String get plansFeatureBirthdayMulti => 'Promo cumpleañero por establecimiento';

  @override
  String get plansFeatureLoyaltySingle => 'Programa de fidelización';

  @override
  String get plansFeatureLoyaltyMulti => 'Programa de fidelización por establecimiento';

  @override
  String get plansFeatureStats => 'Estadísticas en tiempo real';

  @override
  String plansFeaturePush(Object count) {
    return '$count notificaciones push/mes';
  }

  @override
  String get plansActivePlanButton => 'Plan activo';

  @override
  String get plansProcessing => 'Procesando...';

  @override
  String get plansSubscribe => 'Suscribirme';

  @override
  String get plansHaveDiscountQuestion => '¿Tienes un código de descuento?';

  @override
  String get plansDiscountHint => 'Código (opcional)';

  @override
  String get plansApplyCode => 'Aplicar';

  @override
  String get plansContinuePayment => 'Continuar al pago';

  @override
  String get plansCancel => 'Cancelar';

  @override
  String get plansDiscountInvalid => 'Código no válido o no disponible.';

  @override
  String get plansDiscountAlreadyUsed => 'Ya usaste este código.';

  @override
  String get plansDiscountPerMonth => '/mes';

  @override
  String get plansDiscountFreeMonthsLabel => 'meses gratis';

  @override
  String get plansDiscountThen => 'luego';

  @override
  String get plansAddonsLabel => 'ADD-ONS';

  @override
  String get plansAddonsDescription => 'Amplía tu plan con complementos mensuales. Se cobran cada mes y los cancelas cuando quieras.';

  @override
  String get plansAddonEstablishmentTitle => '1 establecimiento adicional';

  @override
  String get plansAddonEstablishmentDesc => 'Un local extra en tu cuenta. Se cobra cada mes hasta que lo canceles.';

  @override
  String get plansAddonEstablishmentPrice => '\$199 MXN/mes';

  @override
  String get plansAddonPromotionTitle => '1 promoción adicional';

  @override
  String get plansAddonPromotionDesc => 'Una promoción extra en cualquier local. Se cobra cada mes hasta que la canceles.';

  @override
  String get plansAddonPromotionPrice => '\$49 MXN/mes';

  @override
  String get plansBuy => 'Comprar';

  @override
  String get plansActiveAddonsTitle => 'Mis complementos activos';

  @override
  String get plansActiveAddonsSubtitle => 'Se renuevan cada mes. Cancélalos cuando quieras.';

  @override
  String get plansAddonPromotionLabel => 'Promoción adicional';

  @override
  String get plansAddonEstablishmentLabel => 'Establecimiento adicional';

  @override
  String get plansCancelAddonTitle => 'Cancelar complemento';

  @override
  String plansCancelAddonConfirm(Object label) {
    return '¿Cancelar \"$label\"? Dejará de cobrarse el próximo mes.';
  }

  @override
  String plansCancelAddonConfirmWithPromos(Object count, Object label) {
    return 'Se desactivarán $count promoción(es) y se cancelará \"$label\". ¿Continuar?';
  }

  @override
  String get plansNo => 'No';

  @override
  String get plansYesCancel => 'Sí, cancelar';

  @override
  String get plansAddonCancelled => 'Complemento cancelado.';

  @override
  String get plansCancelError => 'No se pudo cancelar. Intenta de nuevo.';

  @override
  String plansDeactivateDialogTitle(Object count) {
    return 'Desactiva $count promoción(es)';
  }

  @override
  String plansDeactivateDialogBody(Object count) {
    return 'Al cancelar este complemento superas tu límite. Elige $count para desactivar:';
  }

  @override
  String get plansPromoFallback => 'Promo';

  @override
  String get plansContinue => 'Continuar';

  @override
  String get paymentSecureTitle => 'Pago seguro';

  @override
  String get paymentOpeningBrowser => 'Abriendo MercadoPago en tu navegador...';

  @override
  String get paymentCancelTooltip => 'Cancelar pago';

  @override
  String get profileTitle => 'Mi perfil';

  @override
  String get profileSignOut => 'Cerrar sesión';

  @override
  String get profileNoName => 'Sin nombre';

  @override
  String get profileBusinessOwnerChip => 'Dueño de negocio';

  @override
  String get profileLevelBusinessActive => 'Negocio activo';

  @override
  String get profileLevelStaff => 'Empleado';

  @override
  String get profileAccountInfoTitle => 'Información de la cuenta';

  @override
  String get profileFieldName => 'Nombre';

  @override
  String get profileFieldBirthDate => 'Fecha de nacimiento';

  @override
  String get profileFieldGender => 'Género';

  @override
  String get profileGenderMale => 'Hombre';

  @override
  String get profileGenderFemale => 'Mujer';

  @override
  String get profileGenderOther => 'Otro';

  @override
  String get profileBusinessMembershipTitle => 'Membresía de negocio';

  @override
  String get profileGoToMyBusiness => 'Ir a Mi negocio';

  @override
  String get profileViewPlansAndPayments => 'Ver planes y pagos';

  @override
  String get profileBasicPlan => 'Plan básico';

  @override
  String get profileNoExpiry => 'Sin vencimiento';

  @override
  String profileExpired(Object date) {
    return 'Vencido ($date)';
  }

  @override
  String profileExpiresOn(Object date) {
    return 'Vence el $date';
  }

  @override
  String get profileHaveBusinessTitle => '¿Tienes un negocio?';

  @override
  String get profileHaveBusinessSubtitle => 'Regístralo y llega a más clientes';

  @override
  String get profileRegisterIt => 'Regístralo';

  @override
  String get profileSheetTitleLoaded => 'Ya está en Promofy';

  @override
  String get profileSheetTitleCode => 'Ingresa tu código';

  @override
  String get profileSheetTitleNoCode => 'Encuentra tu negocio';

  @override
  String get profileSheetTitleInitial => 'Registra tu negocio';

  @override
  String get profileOptionNewTitle => 'Es nuevo';

  @override
  String get profileOptionNewSubtitle => 'Quiero registrar mi negocio en Promofy';

  @override
  String get profileOptionLoadedTitle => 'Ya está cargado';

  @override
  String get profileOptionLoadedSubtitle => 'Mi negocio ya existe en Promofy';

  @override
  String get profileOptionHaveCodeTitle => 'Tengo código';

  @override
  String get profileOptionHaveCodeSubtitle => 'Ingresar mi código de invitación';

  @override
  String get profileOptionNoCodeTitle => 'No tengo código';

  @override
  String get profileOptionNoCodeSubtitle => 'Buscar mi negocio por nombre y dirección';

  @override
  String get profileEnterInvitationCode => 'Ingresa tu código de invitación.';

  @override
  String get profileInvalidCode => 'Código inválido.';

  @override
  String get profileConnectionError => 'Error de conexión.';

  @override
  String get profileInvitationCodeHint => 'CÓDIGO DE INVITACIÓN';

  @override
  String get profileVerifyCode => 'Verificar código';

  @override
  String get profileValidCode => '¡Código válido!';

  @override
  String get profileEstablishmentFound => 'Establecimiento encontrado';

  @override
  String get profileChooseMyPlan => 'Elegir mi plan';

  @override
  String get profileBusinessNameHint => 'Nombre de tu negocio';

  @override
  String get profileAddressHint => 'Dirección (calle, número, colonia…)';

  @override
  String get profileEnterBusinessName => 'Ingresa el nombre de tu negocio.';

  @override
  String get profileSearchError => 'Error al buscar. Intenta de nuevo.';

  @override
  String get profileSearchMyBusiness => 'Buscar mi negocio';

  @override
  String get profileNoMatches => 'No encontramos coincidencias.\nRevisa el nombre o la dirección.';

  @override
  String get profileSelectYourBusiness => 'Selecciona tu negocio:';

  @override
  String get profileYourBusiness => 'Tu negocio';

  @override
  String get profileAddressMatchQuestion => 'Verificamos que la dirección coincide. ¿Es tu negocio?';

  @override
  String get profileYesItsMineChoosePlan => 'Sí, es mío — Elegir plan';

  @override
  String get profileNotThisBusiness => 'No es este negocio';

  @override
  String get profileBack => 'Volver';

  @override
  String get profileFavoritesTitle => 'Mis favoritos';

  @override
  String get profileFavoritesSubtitle => 'Promos y negocios que guardaste';

  @override
  String get profileSettingsTitle => 'Configuración';

  @override
  String get profileSettingsSubtitle => 'Nombre, radio, gustos, contraseña y cuenta';

  @override
  String get profileWorkplacesTitle => 'Mis lugares de trabajo';

  @override
  String get profileNoWorkplaces => 'No se encontraron establecimientos asociados.';

  @override
  String get profileRoleManager => 'Gerente';

  @override
  String get profileRoleCashierWaiter => 'Cajero / Mesero';

  @override
  String get profileRoleCashier => 'Cajero';

  @override
  String get profileRoleCustom => 'Personalizado';

  @override
  String profileRoleLabel(Object role) {
    return 'Rol: $role';
  }

  @override
  String get profilePermLoyaltyQr => 'QR lealtad';

  @override
  String get profilePermStats => 'Estadísticas';

  @override
  String get profilePermPromos => 'Promos';

  @override
  String get profileWorkAtBusinessTitle => '¿Trabajas en un negocio?';

  @override
  String get profileWorkAtBusinessSubtitle => 'Ingresa tu código de invitación';

  @override
  String get profileJoin => 'Unirse';

  @override
  String get profileLinkCopied => '¡Link copiado al portapapeles!';

  @override
  String profileReferralShareText(Object url) {
    return '¡Únete a Promofy y atrae más clientes a tu negocio!\nCrea tu cuenta con mi link y ambos ganamos:\n$url';
  }

  @override
  String get profileReferralShareSubject => 'Únete a Promofy';

  @override
  String get profileReferralTitle => 'Programa de referidos';

  @override
  String get profileReferralDescription => 'Invita a otros negocios con tu link. Cuando activen una membresía de pago, recibes \$300 MXN en créditos de publicidad.';

  @override
  String get profileCreditsEarned => 'Créditos ganados';

  @override
  String get profileCopied => 'Copiado';

  @override
  String get profileCopyLink => 'Copiar link';

  @override
  String get profileShare => 'Compartir';

  @override
  String get profileReferralLinkSoon => 'Tu link de referido estará disponible en breve.';

  @override
  String get profileReferralHaveCodeTitle => '¿Te invitaron?';

  @override
  String get profileReferralCodeHint => 'Código de invitación';

  @override
  String get profileReferralApply => 'Aplicar';

  @override
  String get profileReferralOk => '¡Código aplicado! 🎉';

  @override
  String get profileReferralAlready => 'Ya tenías un código de invitación registrado.';

  @override
  String get profileReferralNotFound => 'Código no válido.';

  @override
  String get profileReferralSelf => 'No puedes usar tu propio código.';

  @override
  String get profileReferralGenericError => 'No se pudo aplicar el código.';

  @override
  String get profileAchievementsTitle => 'Mis Logros';

  @override
  String get profileSeeAll => 'Ver todos';

  @override
  String profileVisitsToNextBadge(Object visits, Object toGo, Object nextBadge) {
    return '$visits visitas · faltan $toGo para $nextBadge';
  }

  @override
  String profileVisitsMaxLevel(Object visits) {
    return '$visits visitas este año — ¡nivel máximo!';
  }

  @override
  String profileStreakWeeks(Object weeks) {
    return '$weeks sem. en racha';
  }

  @override
  String profileTopInCity(Object percent) {
    return 'Top $percent% en tu ciudad';
  }

  @override
  String get profileWelcomeToTeam => '¡Bienvenido al equipo!';

  @override
  String get profileJoinATeam => 'Unirse a un equipo';

  @override
  String get profileContinue => 'Continuar';

  @override
  String get profileCancel => 'Cancelar';

  @override
  String get profileJoinMe => 'Unirme';

  @override
  String get profileCodeSixChars => 'El código debe tener 6 caracteres.';

  @override
  String get profileCodeInvalidOrExpired => 'Código inválido o expirado.';

  @override
  String get profileConnectionErrorRetry => 'Error de conexión. Intenta de nuevo.';

  @override
  String get profileEnterSixCharCode => 'Ingresa el código de 6 caracteres que te compartió el administrador.';

  @override
  String get profileWillUpdateOnContinue => 'Tu perfil se actualizará al continuar.';

  @override
  String get settingsName => 'Nombre';

  @override
  String get settingsNameHint => 'Tu nombre completo';

  @override
  String get settingsNameEmpty => 'El nombre no puede estar vacío.';

  @override
  String get settingsSearchRadius => 'Radio de búsqueda';

  @override
  String get settingsPreferredTypes => 'Tipos de lugar preferidos';

  @override
  String get settingsFavoriteFood => 'Comida favorita';

  @override
  String get settingsLoadingCategories => 'Cargando categorías…';

  @override
  String get settingsSaveButton => 'Guardar configuración';

  @override
  String get settingsSaved => 'Configuración guardada.';

  @override
  String get settingsSaveError => 'Error al guardar. Intenta de nuevo.';

  @override
  String get settingsAccountSecurity => 'Cuenta y seguridad';

  @override
  String get settingsChangePassword => 'Cambiar contraseña';

  @override
  String get settingsNewPassword => 'Nueva contraseña';

  @override
  String get settingsConfirmPassword => 'Confirmar contraseña';

  @override
  String get settingsPasswordMin => 'Mínimo 6 caracteres';

  @override
  String get settingsPasswordMismatch => 'No coinciden';

  @override
  String get settingsPasswordUpdated => 'Contraseña actualizada.';

  @override
  String get settingsPasswordError => 'No se pudo cambiar la contraseña. Intenta de nuevo.';

  @override
  String get settingsCancel => 'Cancelar';

  @override
  String get settingsSave => 'Guardar';

  @override
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsDeleteConfirmTitle => '¿Estás seguro?';

  @override
  String get settingsDeleteConfirmBody => 'Perderás toda tu información: tu perfil, favoritos, sellos de lealtad, historial y, si tienes un negocio, sus datos asociados.\n\nEsta acción es permanente y no se puede deshacer.';

  @override
  String settingsDeleteError(Object email) {
    return 'No se pudo eliminar la cuenta. Escríbenos a $email';
  }

  @override
  String get bizMyBusiness => 'Mi negocio';

  @override
  String get bizEditInfo => 'Editar información';

  @override
  String bizPromoLimitReached(Object max) {
    return 'Llegaste a tu límite de $max promociones. Compra espacio extra o sube de plan para agregar más.';
  }

  @override
  String bizEstablishmentLimitReached(Object plan, Object max) {
    return 'Tu plan \"$plan\" permite hasta $max establecimientos. Actualiza tu plan para agregar más.';
  }

  @override
  String get bizStatsTitle => 'Estadísticas de tu negocio';

  @override
  String get bizStatsGateDesc => 'Activa un plan para ver impresiones, favoritos y demografía de tu audiencia.';

  @override
  String get bizViewPlans => 'Ver planes';

  @override
  String get bizUsageBusinesses => 'neg.';

  @override
  String get bizUsagePromos => 'promos';

  @override
  String get bizUpgrade => 'Upgrade ↗';

  @override
  String get bizAdd => 'Agregar';

  @override
  String get bizBusinessInfo => 'Información del negocio';

  @override
  String get bizNoExtraInfo => 'Sin información adicional.';

  @override
  String get bizTypeLocal => 'Local';

  @override
  String get bizTypeUrbanMobile => 'Urbano / Móvil';

  @override
  String get bizPaymentCard => 'Tarjeta crédito/débito';

  @override
  String get bizPaymentCash => 'Efectivo';

  @override
  String get bizPaymentOther => 'Otro';

  @override
  String get bizAdultPromotions => 'Tiene promociones para adultos';

  @override
  String get bizDayMonday => 'Lunes';

  @override
  String get bizDayTuesday => 'Martes';

  @override
  String get bizDayWednesday => 'Miércoles';

  @override
  String get bizDayThursday => 'Jueves';

  @override
  String get bizDayFriday => 'Viernes';

  @override
  String get bizDaySaturday => 'Sábado';

  @override
  String get bizDaySunday => 'Domingo';

  @override
  String get bizScheduleTitle => 'Horario de atención';

  @override
  String get bizClosed => 'Cerrado';

  @override
  String get bizMyPromos => 'Mis promociones';

  @override
  String get bizFeaturedHint => 'Activa \"Destacada\" para que tu promo aparezca primero en la búsqueda.';

  @override
  String get bizNoPromosYet => 'Aún no tienes promociones en este negocio.';

  @override
  String get bizPlanLimitTitle => 'Llegaste al límite de tu plan';

  @override
  String get bizBuyExtraSpaceDesc => 'Compra espacio extra y sigue publicando sin cambiar de plan.';

  @override
  String get bizBuyPromoSpace => 'Comprar espacio de promoción';

  @override
  String bizEditAvailableOn(Object date) {
    return 'Edición disponible el $date';
  }

  @override
  String get bizPromoNotEditableYet => 'Esta promoción aún no puede editarse.';

  @override
  String bizEditableOn(Object date) {
    return 'Editable el $date';
  }

  @override
  String get bizLocked => 'Bloqueada';

  @override
  String get bizFeatured => 'Destacada';

  @override
  String get bizFlash => 'Flash';

  @override
  String get bizMyTeam => 'Mi equipo';

  @override
  String get bizInvite => 'Invitar';

  @override
  String get bizRemoveFromTeamTitle => 'Eliminar del equipo';

  @override
  String bizRemoveFromTeamConfirm(Object name) {
    return '¿Quitar a $name del equipo?';
  }

  @override
  String get bizCancel => 'Cancelar';

  @override
  String get bizRemove => 'Quitar';

  @override
  String bizRemoveTeamError(Object error) {
    return 'Error al quitar del equipo: $error';
  }

  @override
  String get bizNoStaffYet => 'Sin empleados aún.\nToca \"Invitar\" para generar un código.';

  @override
  String get bizRemoveFromTeamTooltip => 'Quitar del equipo';

  @override
  String bizGenerateCodeError(Object error) {
    return 'Error al generar código: $error';
  }

  @override
  String get bizInviteStaff => 'Invitar empleado';

  @override
  String get bizCodeAvailable48h => 'El código estará disponible por 48 horas.';

  @override
  String get bizRoleLabel => 'ROL';

  @override
  String get bizRoleCashier => 'Cajero / Mesero';

  @override
  String get bizRoleCashierDesc => 'Solo puede escanear el QR de lealtad';

  @override
  String get bizRoleManager => 'Gerente';

  @override
  String get bizRoleManagerDesc => 'Estadísticas, promos y QR de lealtad';

  @override
  String get bizRoleCustom => 'Personalizado';

  @override
  String get bizRoleCustomDesc => 'Elige los permisos manualmente';

  @override
  String get bizPermissionsLabel => 'PERMISOS';

  @override
  String get bizPermScanQr => 'Escanear QR de lealtad';

  @override
  String get bizPermViewStats => 'Ver estadísticas';

  @override
  String get bizPermManagePromos => 'Gestionar promociones';

  @override
  String get bizPermManagePayments => 'Gestionar pagos';

  @override
  String get bizGenerating => 'Generando…';

  @override
  String get bizGenerateCode => 'Generar código';

  @override
  String get bizCodeGenerated => 'Código generado';

  @override
  String bizCodeRole(Object role) {
    return 'Rol: $role';
  }

  @override
  String get bizCodeValid48h => 'Válido por 48 horas.\nCompartir con el empleado para que lo ingrese en la app.';

  @override
  String get bizCodeCopied => 'Código copiado';

  @override
  String get bizCopyCode => 'Copiar código';

  @override
  String get bizDone => 'Listo';

  @override
  String get bizPushNotifications => 'Notificaciones push';

  @override
  String get bizNoNotifications => 'Sin notificaciones en este período.\nSe generan automáticamente al crear una promo flash.';

  @override
  String get bizKpiSent => 'Envíos';

  @override
  String get bizKpiReached => 'Alcanzados';

  @override
  String get bizKpiOpenRate => 'Tasa apertura';

  @override
  String get bizRecentHistory => 'HISTORIAL RECIENTE';

  @override
  String bizNotifSentLine(Object date, Object count) {
    return '$date · $count enviadas';
  }

  @override
  String bizOpenRateShort(Object pct) {
    return '$pct% apert.';
  }

  @override
  String get bizBoostBusiness => 'Impulsa tu negocio';

  @override
  String bizPlanIncludes(Object plan, Object establishments, Object promotions) {
    return 'Tu plan \"$plan\" incluye hasta $establishments negocios y $promotions promociones normales.';
  }

  @override
  String get bizEmptyTagline => 'Publica promociones y llega a miles de clientes en tu ciudad.';

  @override
  String get bizRegisterMyBusiness => 'Registrar mi negocio';

  @override
  String get bizAdvertising => 'Publicidad';

  @override
  String get bizNewCampaign => 'Nueva campaña';

  @override
  String get bizAvailableCredit => 'Crédito disponible';

  @override
  String bizReachableBanner(Object count) {
    return '≈ $count personas alcanzables (banner)';
  }

  @override
  String get bizTopUp => 'Recargar';

  @override
  String get bizWalletTitle => 'Cartera Promofy';

  @override
  String get bizWalletUse => 'Usar';

  @override
  String get bizWalletDialogTitle => 'Usar créditos de cartera';

  @override
  String get bizWalletDialogDesc => 'Mueve crédito de tu cartera al saldo de publicidad de este local. Ese saldo sí se gasta en tus anuncios.';

  @override
  String get bizWalletAll => 'Todo';

  @override
  String get bizWalletApply => 'Aplicar';

  @override
  String get bizWalletCancel => 'Cancelar';

  @override
  String get bizWalletInvalid => 'Monto inválido.';

  @override
  String get bizWalletInsufficient => 'No tienes suficiente saldo en la cartera.';

  @override
  String get bizWalletError => 'No se pudo aplicar el crédito.';

  @override
  String get bizWalletApplied => '¡Listo! Crédito aplicado al saldo del local.';

  @override
  String get bizNoActiveCampaigns => 'Sin campañas activas';

  @override
  String get bizOngoingCampaigns => 'Campañas en curso';

  @override
  String bizSpent(Object amount) {
    return 'Gastado: $amount';
  }

  @override
  String bizBudget(Object amount) {
    return 'Presupuesto: $amount';
  }

  @override
  String get bizPause => 'Pausar';

  @override
  String get bizResume => 'Reanudar';

  @override
  String get bizTransactionHistory => 'Historial de movimientos';

  @override
  String get bizRetry => 'Reintentar';

  @override
  String get bizGeoBoth => 'Física + búsqueda';

  @override
  String get bizGeoPhysical => 'Solo ubicación física';

  @override
  String get bizGeoSearchArea => 'Solo área de búsqueda';

  @override
  String get bizErrorNameRequired => 'El nombre es obligatorio';

  @override
  String get bizErrorBudgetInvalid => 'Ingresa un presupuesto válido';

  @override
  String bizErrorMinBudget(Object amount) {
    return 'Presupuesto mínimo para este formato: $amount';
  }

  @override
  String bizErrorInsufficientBalance(Object amount) {
    return 'Saldo insuficiente. Disponible: $amount';
  }

  @override
  String get bizErrorSelectPromo => 'Selecciona la promoción que quieres publicitar';

  @override
  String get bizCampaignName => 'Nombre de la campaña';

  @override
  String get bizWhatToAdvertise => '¿Qué publicitarás?';

  @override
  String get bizYourBusiness => 'Tu negocio';

  @override
  String get bizOnePromotion => 'Una promoción';

  @override
  String get bizWhereToShow => '¿Dónde quieres mostrarlo?';

  @override
  String get bizPlacementSplash => 'Splash al abrir la app';

  @override
  String get bizPlacementFeed => 'En el feed de promos';

  @override
  String get bizPlacementBanner => 'Banner en el inicio';

  @override
  String get bizSpecialFormats => 'Formatos especiales';

  @override
  String get bizFormatPush => 'Notif. push';

  @override
  String get bizFormatFlash => 'Promo Relámpago';

  @override
  String get bizBudgetMxn => 'Presupuesto (MXN)';

  @override
  String bizMinimum(Object amount) {
    return 'Mínimo $amount';
  }

  @override
  String bizEstimatedReach(Object count) {
    return 'Alcance estimado: $count personas';
  }

  @override
  String get bizRadius => 'Radio:';

  @override
  String get bizGeoSegmentation => 'Segmentación geográfica';

  @override
  String get bizAge => 'Edad:';

  @override
  String bizAgeRange(Object min, Object max) {
    return '$min – $max años';
  }

  @override
  String bizYearsOld(Object age) {
    return '$age años';
  }

  @override
  String get bizGender => 'Sexo';

  @override
  String get bizGenderAll => 'Todos';

  @override
  String get bizGenderMale => 'Hombres';

  @override
  String get bizGenderFemale => 'Mujeres';

  @override
  String bizAudienceWithFilters(Object count) {
    return 'Audiencia con estos filtros: $count personas';
  }

  @override
  String get bizCalculatingAudience => 'Calculando audiencia...';

  @override
  String get bizPromoToAdvertise => 'Promoción a publicitar';

  @override
  String get bizCreatePromoFirst => 'Crea al menos una promoción activa antes de lanzar una campaña.';

  @override
  String get bizLaunchCampaign => 'Lanzar campaña';

  @override
  String get bizRefresh => 'Actualizar';

  @override
  String get bizNoAssignedEstablishments => 'Sin establecimientos asignados';

  @override
  String get bizAskOwnerToInvite => 'Pide al dueño del negocio que te invite con un código.';

  @override
  String get bizPermManagePromosShort => 'Gestionar promos';

  @override
  String get bizScanStamps => 'Escanear sellos';

  @override
  String get bizPromoTypeFlash => 'Flash';

  @override
  String get bizPromoTypeDaily => 'Diaria';

  @override
  String get bizPromoTypeWeekly => 'Semanal';

  @override
  String get bizPromoTypePermanent => 'Permanente';

  @override
  String get bizActive => 'Activa';

  @override
  String get bizInactive => 'Inactiva';

  @override
  String get bizMinAmount50 => 'Ingresa un monto mínimo de \$50 MXN';

  @override
  String get bizCannotOpenMercadoPago => 'No se pudo abrir MercadoPago';

  @override
  String get bizRedirectedToMercadoPago => 'Redirigido a MercadoPago. El saldo se actualizará en minutos tras el pago.';

  @override
  String get bizTopUpAdCredit => 'Recargar crédito publicitario';

  @override
  String get bizTopUpDesc => 'Cada impresión deduce crédito según el formato de la campaña. El pago es procesado por MercadoPago.';

  @override
  String get bizAmountToTopUp => 'MONTO A RECARGAR';

  @override
  String get bizOtherAmount => 'Otro monto';

  @override
  String get bizMin50Mxn => 'Mínimo \$50 MXN';

  @override
  String bizTotalToPay(Object amount) {
    return 'Total a pagar: $amount MXN';
  }

  @override
  String get bizPreparingPayment => 'Preparando pago…';

  @override
  String get bizPayWithMercadoPago => 'Pagar con MercadoPago';

  @override
  String get bizWillRedirectMercadoPago => 'Serás redirigido al sitio de MercadoPago.';

  @override
  String get regBizCreateTitle => 'Registrar negocio';

  @override
  String get regBizEditTitle => 'Editar negocio';

  @override
  String get regBizBack => 'Atrás';

  @override
  String get regBizNext => 'Siguiente';

  @override
  String get regBizSaveChanges => 'Guardar cambios';

  @override
  String regBizStepOf(Object step, Object total) {
    return 'Paso $step de $total';
  }

  @override
  String get regBizStepBasic => 'Datos básicos';

  @override
  String get regBizStepType => 'Tipo y categoría';

  @override
  String get regBizStepSchedule => 'Horario y extras';

  @override
  String get regBizUpdatedOk => 'Negocio actualizado correctamente.';

  @override
  String get regBizCreatedOk => '¡Negocio registrado! Ya apareces en Promofy.';

  @override
  String get regBizSelectAddressHint => 'Selecciona una dirección del buscador para obtener la ubicación.';

  @override
  String get regBizSelectType => 'Selecciona el tipo de establecimiento.';

  @override
  String get regBizSelectCategory => 'Selecciona al menos una categoría.';

  @override
  String get regBizSelectCharacteristic => 'Selecciona al menos una característica.';

  @override
  String get regBizSelectPayment => 'Selecciona al menos un método de pago.';

  @override
  String get regBizSelectDay => 'Agrega al menos un día de atención.';

  @override
  String get regBizSectionMain => 'Información principal';

  @override
  String get regBizNameLabel => 'Nombre del negocio *';

  @override
  String get regBizNameHint => 'Ej. Tacos El Gordo';

  @override
  String get regBizNameRequired => 'El nombre es obligatorio';

  @override
  String get regBizDescLabel => 'Descripción';

  @override
  String get regBizDescHint => 'Describe brevemente tu negocio…';

  @override
  String get regBizSectionLocation => 'Ubicación';

  @override
  String get regBizAddressLabel => 'Dirección';

  @override
  String get regBizAddressLabelRequired => 'Dirección *';

  @override
  String get regBizAddressHint => 'Toca para buscar la dirección…';

  @override
  String get regBizAddressHelper => 'Selecciona la dirección de las sugerencias para obtener coordenadas.';

  @override
  String get regBizSectionContact => 'Contacto';

  @override
  String get regBizPhoneLabel => 'Teléfono / WhatsApp';

  @override
  String get regBizPhoneHint => 'Ej. 4491234567';

  @override
  String get regBizSectionSocial => 'Redes sociales';

  @override
  String get regBizWebsiteLabel => 'Sitio web';

  @override
  String get regBizTypeSection => 'Tipo de establecimiento *';

  @override
  String get regBizTypeLocal => 'Local';

  @override
  String get regBizTypeLocalSub => 'Dirección fija';

  @override
  String get regBizTypeMobile => 'Urbano / Móvil';

  @override
  String get regBizTypeMobileSub => 'Ubicación variable';

  @override
  String get regBizCategorySection => 'Categoría *';

  @override
  String get regBizCategoryHelper => 'Puedes seleccionar una o varias. La subcategoría es opcional.';

  @override
  String get regBizSubcategoryLabel => '↳ Subcategoría (opcional)';

  @override
  String get regBizSpecialtyLabel => '↳ Especialidad (opcional)';

  @override
  String get regBizExtraSection => 'Información adicional';

  @override
  String get regBizAdultPromos => '¿Tiene promociones para mayores de edad?';

  @override
  String get regBizScheduleSection => 'Horario de atención *';

  @override
  String get regBizScheduleHelper => 'Activa los días que atiendes y ajusta los horarios.';

  @override
  String get regBizCharSection => 'Características *';

  @override
  String get regBizCharHelper => 'Selecciona las que apliquen a tu negocio.';

  @override
  String get regBizPaymentSection => 'Métodos de pago *';

  @override
  String get regBizPaymentCard => 'Tarjeta crédito/débito';

  @override
  String get regBizPaymentCash => 'Efectivo';

  @override
  String get regBizPaymentOther => 'Otro';

  @override
  String get regBizClosed => 'Cerrado';

  @override
  String get regBizDayMonday => 'Lunes';

  @override
  String get regBizDayTuesday => 'Martes';

  @override
  String get regBizDayWednesday => 'Miércoles';

  @override
  String get regBizDayThursday => 'Jueves';

  @override
  String get regBizDayFriday => 'Viernes';

  @override
  String get regBizDaySaturday => 'Sábado';

  @override
  String get regBizDaySunday => 'Domingo';

  @override
  String get regBizSearchAddressTitle => 'Buscar dirección';

  @override
  String get regBizSearchAddressHint => 'Escribe la dirección de tu negocio…';

  @override
  String get regBizNoResults => 'Sin resultados. Intenta con otra búsqueda.';

  @override
  String get regBizSearchError => 'Error al buscar. Intenta de nuevo.';

  @override
  String get regBizLocationError => 'No se pudo obtener la ubicación.';

  @override
  String get promoFormEditTitle => 'Editar promoción';

  @override
  String get promoFormNewTitle => 'Nueva promoción';

  @override
  String get promoFormDelete => 'Eliminar';

  @override
  String get promoFormCancel => 'Cancelar';

  @override
  String get promoFormClear => 'Limpiar';

  @override
  String get promoFormSelectThis => 'Seleccionar esta';

  @override
  String get promoFormCategorySheetTitle => 'Categoría de la promoción';

  @override
  String get promoFormCategoryLevel1 => 'Categoría';

  @override
  String get promoFormSubcategory => 'Subcategoría';

  @override
  String get promoFormSpecialty => 'Especialidad';

  @override
  String get promoFormOptionalTag => 'opcional';

  @override
  String get promoFormStartDate => 'Fecha de inicio';

  @override
  String get promoFormEndDate => 'Fecha de fin';

  @override
  String get promoFormStartTime => 'Hora de inicio';

  @override
  String get promoFormEndTime => 'Hora de fin';

  @override
  String get promoFormEndTimeSameDay => 'Hora de fin (mismo día)';

  @override
  String get promoFormErrorNameRequired => 'El nombre es obligatorio.';

  @override
  String get promoFormErrorSelectDay => 'Selecciona al menos un día.';

  @override
  String get promoFormErrorStartDateTime => 'Indica la fecha y hora de inicio.';

  @override
  String get promoFormErrorEndTime => 'Indica la hora de fin.';

  @override
  String get promoFormErrorEndAfterStart => 'La hora de fin debe ser posterior al inicio.';

  @override
  String get promoFormErrorSameDay => 'La promo flash debe iniciar y terminar el mismo día.';

  @override
  String get promoFormConfirmTitle => '¿Todo está correcto?';

  @override
  String promoFormConfirmName(Object name) {
    return '\"$name\"';
  }

  @override
  String get promoFormConfirmIntro => 'Una vez creada, ';

  @override
  String get promoFormConfirmLockWarning => 'no podrás editar esta promoción durante 15 días.';

  @override
  String get promoFormConfirmReview => '\n\nRevisa con detalle el nombre, descripción, horarios y días activos antes de continuar.';

  @override
  String get promoFormReviewMore => 'Revisar más';

  @override
  String get promoFormConfirmCreate => 'Sí, crear promoción';

  @override
  String promoFormSaveError(Object error) {
    return 'Error al guardar: $error';
  }

  @override
  String get promoFormDeleteTitle => 'Eliminar promoción';

  @override
  String get promoFormDeleteConfirm => '¿Eliminar esta promoción? Esta acción no se puede deshacer.';

  @override
  String promoFormDeleteError(Object error) {
    return 'Error al eliminar: $error';
  }

  @override
  String get promoFormTypeLabel => 'Tipo de promoción';

  @override
  String get promoFormTypeNormal => 'Normal';

  @override
  String get promoFormTypeFlash => 'Flash ⚡';

  @override
  String get promoFormTypeBirthday => 'Cumpleañero 🎂';

  @override
  String get promoFormTypeNormalDesc => 'Se repite cada semana en los días y horario elegidos.';

  @override
  String get promoFormTypeFlashDesc => 'Evento único, válido un solo día. Máximo 1 flash por mes.';

  @override
  String get promoFormTypeBirthdayDesc => 'Disponible todos los días del año para clientes que cumplan años.';

  @override
  String get promoFormNameLabel => 'Nombre *';

  @override
  String get promoFormNameHint => 'Ej: 2x1 en micheladas';

  @override
  String get promoFormDescriptionLabel => 'Descripción';

  @override
  String get promoFormDescriptionHint => 'Cuéntale a tus clientes los detalles';

  @override
  String get promoFormBirthdayGiftLabel => 'Regalo de cumpleaños *';

  @override
  String get promoFormBirthdayGiftHint => 'Ej: Postre gratis, copa de cortesía…';

  @override
  String get promoFormBirthdayTermsLabel => 'Condiciones (opcional)';

  @override
  String get promoFormBirthdayTermsHint => 'Ej: Presentar ID el día de tu cumpleaños';

  @override
  String get promoFormPhotoLabel => 'Foto (opcional)';

  @override
  String get promoFormPhotoTapToAdd => 'Toca para agregar foto';

  @override
  String get promoFormCategoryLabel => 'Categoría (opcional)';

  @override
  String get promoFormCategorySelected => 'Categoría seleccionada';

  @override
  String get promoFormCategoryLoading => 'Cargando categorías...';

  @override
  String get promoFormCategoryNone => 'Sin categoría';

  @override
  String get promoFormAdultTitle => 'Contenido para adultos';

  @override
  String get promoFormAdultSubtitle => 'Solo visible para usuarios +18';

  @override
  String get promoFormSaveChanges => 'Guardar cambios';

  @override
  String get promoFormCreate => 'Crear promoción';

  @override
  String get promoFormActiveDaysLabel => 'Días activos *';

  @override
  String get promoFormScheduleLabel => 'Horario';

  @override
  String get promoFormStartLabel => 'Inicio';

  @override
  String get promoFormEndLabel => 'Fin';

  @override
  String get promoFormEventStartLabel => 'Inicio del evento *';

  @override
  String get promoFormEventEndLabel => 'Fin del evento *';

  @override
  String get promoFormEndTimeSameDayLabel => 'Hora de fin * (mismo día)';

  @override
  String get promoFormPickDateTime => 'Seleccionar fecha y hora';

  @override
  String get promoFormPickEndTime => 'Seleccionar hora de fin';

  @override
  String get promoFormFlashInfo => 'La promo flash debe comenzar y terminar el mismo día. Solo se permite una por mes por negocio.';

  @override
  String get adminPlacesTitle => 'Admin Lugares';

  @override
  String get adminPlacesRefresh => 'Actualizar';

  @override
  String get adminPlacesTabEstablishments => 'Establecimientos';

  @override
  String get adminPlacesTabPromos => 'Promociones';

  @override
  String get adminPlacesAddPlace => 'Agregar lugar';

  @override
  String get adminPlacesSearchHint => 'Buscar…';

  @override
  String adminPlacesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lugares',
      one: '1 lugar',
    );
    return '$_temp0';
  }

  @override
  String get adminPlacesEmpty => 'Aún no hay lugares. Toca + para agregar uno.';

  @override
  String get adminPlacesNoResults => 'Sin resultados.';

  @override
  String get adminPlacesEditInfo => 'Editar info';

  @override
  String get adminPlacesManagePhotos => 'Gestionar fotos';

  @override
  String get adminPlacesDelete => 'Eliminar';

  @override
  String get adminPlacesManagePromos => 'Gestionar promociones';

  @override
  String adminPlacesPhotosTitle(Object name) {
    return 'Fotos — $name';
  }

  @override
  String get adminPlacesDeleteTitle => 'Eliminar lugar';

  @override
  String adminPlacesDeleteConfirm(Object name) {
    return '¿Eliminar \"$name\"?\nTambién eliminará sus promociones.';
  }

  @override
  String get adminPlacesCancel => 'Cancelar';

  @override
  String adminPlacesError(Object error) {
    return 'Error: $error';
  }

  @override
  String get adminPlacesNoPlacesYet => 'Primero crea un lugar en la pestaña Establecimientos.';

  @override
  String get adminPlacesSelectPlace => 'Selecciona un lugar';

  @override
  String get adminPlacesNewPromo => 'Nueva promoción';

  @override
  String get adminPlacesChoosePlace => 'Elige un lugar para ver sus promociones.';

  @override
  String get adminPlacesNoPromos => 'Sin promociones. Toca \"Nueva promoción\".';

  @override
  String get adminPlacesPromoActive => 'Activa';

  @override
  String get adminPlacesPromoInactive => 'Inactiva';

  @override
  String get adminPlacesEdit => 'Editar';

  @override
  String get adminMetricsTitle => 'Panel Admin';

  @override
  String get adminMetricsManageRestaurants => 'Gestionar restaurantes';

  @override
  String get adminMetricsRefresh => 'Actualizar métricas';

  @override
  String get adminMetricsRetry => 'Reintentar';

  @override
  String get adminMetricsAdminPlaces => 'Admin Lugares';

  @override
  String get adminMetricsAdminPlacesSubtitle => 'Gestionar establecimientos y promociones del admin';

  @override
  String get adminMetricsSectionUsers => 'Usuarios';

  @override
  String get adminMetricsNewUsers => 'Nuevos usuarios';

  @override
  String get adminMetricsActiveUsers => 'Usuarios activos';

  @override
  String get adminMetricsPeriodToday => 'Hoy';

  @override
  String get adminMetricsPeriod7d => '7 días';

  @override
  String get adminMetricsPeriod15d => '15 días';

  @override
  String get adminMetricsPeriod30d => '30 días';

  @override
  String get adminMetricsPeriodTotal => 'Total';

  @override
  String get adminMetricsSectionPlatform => 'Plataforma';

  @override
  String get adminMetricsEstablishments => 'Establecimientos';

  @override
  String adminMetricsNewThisMonth(Object count) {
    return '$count este mes';
  }

  @override
  String get adminMetricsActivePromos => 'Promos activas';

  @override
  String adminMetricsTotalCount(Object count) {
    return '$count total';
  }

  @override
  String get adminMetricsSectionLoyaltyQr => 'Lealtad & QR';

  @override
  String get adminMetricsTotalScans => 'Escaneos totales';

  @override
  String adminMetricsLast30dValue(Object count) {
    return '$count últimos 30d';
  }

  @override
  String get adminMetricsAvgTicket => 'Ticket promedio';

  @override
  String get adminMetricsWaiterUploadedAmount => 'Monto subido por meseros';

  @override
  String get adminMetricsSectionCampaigns => 'Campañas Publicitarias';

  @override
  String get adminMetricsActiveCampaigns => 'Campañas activas';

  @override
  String get adminMetricsCreditsSold => 'Créditos vendidos';

  @override
  String get adminMetricsLast30days => 'últimos 30 días';

  @override
  String get adminMetricsCampaignSpend => 'Gasto en campañas';

  @override
  String get adminMetricsSectionSubscriptions => 'Suscripciones';

  @override
  String get adminMetricsActiveSubscriptions => 'Suscripciones activas';

  @override
  String get adminMetricsMonthlyIncome => 'ingresos mensuales';

  @override
  String get adminMetricsSectionPerformance => 'Rendimiento';

  @override
  String get adminMetricsRegisteredUsers => 'usuarios registrados';

  @override
  String get adminMetricsRoleUsers => 'Usuarios';

  @override
  String get adminMetricsRoleStaff => 'Staff';

  @override
  String get adminMetricsRoleBusiness => 'Negocios';

  @override
  String get adminMetricsRoleAdmin => 'Admin';

  @override
  String get adminMetricsPlatformRevenue30d => 'Ingresos plataforma (30 días)';

  @override
  String get adminMetricsRevenueSubscriptions => 'Suscripciones\n(MRR)';

  @override
  String get adminMetricsRevenueAdCredits => 'Créditos ad\n(30d)';

  @override
  String get adminMetricsRevenueRoas => 'ROAS\n(ingresos/gasto ad)';

  @override
  String get adminMetricsNotAvailable => 'N/A';

  @override
  String get adminEstTitle => 'Restaurantes Admin';

  @override
  String get adminEstRefresh => 'Actualizar';

  @override
  String get adminEstAdd => 'Agregar restaurante';

  @override
  String get adminEstSearchHint => 'Buscar por nombre o dirección…';

  @override
  String get adminEstLoading => 'Cargando…';

  @override
  String adminEstCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count establecimientos',
      one: '1 establecimiento',
    );
    return '$_temp0';
  }

  @override
  String get adminEstRetry => 'Reintentar';

  @override
  String get adminEstEmpty => 'Aún no hay restaurantes gestionados por Admin.';

  @override
  String adminEstNoResults(Object query) {
    return 'Sin resultados para \"$query\".';
  }

  @override
  String get adminEstAddFirst => 'Agregar primero';

  @override
  String get adminEstDeleteTitle => 'Eliminar restaurante';

  @override
  String adminEstDeleteConfirm(Object name) {
    return '¿Eliminar \"$name\"?\nEsto también eliminará sus promociones y datos asociados.';
  }

  @override
  String get adminEstCancel => 'Cancelar';

  @override
  String get adminEstDelete => 'Eliminar';

  @override
  String adminEstDeleted(Object name) {
    return '\"$name\" eliminado.';
  }

  @override
  String adminEstDeleteError(Object error) {
    return 'Error al eliminar: $error';
  }

  @override
  String get adminEstEdit => 'Editar';

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get statsRetry => 'Reintentar';

  @override
  String get statsBusinessViews => 'Vistas negocio';

  @override
  String get statsPromoViews => 'Vistas promos';

  @override
  String get statsNewFavs => 'Nuevos favs';

  @override
  String get statsContacts => 'Contactos';

  @override
  String get statsQrVisits => 'Visitas QR';

  @override
  String get statsTotalFavs => 'Favs totales';

  @override
  String get statsAvgTicket => 'Ticket prom.';

  @override
  String get statsRevenue => 'Ingresos generados';

  @override
  String get statsPromoBreakdown => 'DETALLE POR PROMO';

  @override
  String get statsColPromo => 'Promo';

  @override
  String get statsColViews => 'Vistas';

  @override
  String get statsColViewsTooltip => 'Veces que abrieron el detalle';

  @override
  String get statsColNewFavs => 'Favs +';

  @override
  String get statsColNewFavsTooltip => 'Nuevos favoritos en el período';

  @override
  String get statsColTotalFavs => 'Favs Σ';

  @override
  String get statsColTotalFavsTooltip => 'Total de favoritos acumulados';

  @override
  String get statsContactChannels => 'CANALES DE CONTACTO';

  @override
  String get statsChannelPhone => 'Llamada';

  @override
  String get statsChannelWebsite => 'Sitio web';

  @override
  String get statsChannelMaps => 'Mapa';

  @override
  String statsAudienceHeader(Object total) {
    return 'AUDIENCIA ($total favoriteadores)';
  }

  @override
  String get statsGender => 'Sexo';

  @override
  String get statsAge => 'Edad';

  @override
  String get statsByPromo => 'Por promoción';

  @override
  String get statsGenderMale => 'Hombres';

  @override
  String get statsGenderFemale => 'Mujeres';

  @override
  String get statsGenderUnknown => 'N/E';

  @override
  String get photosSectionTitle => 'Logo y fotos';

  @override
  String get photosLogoTitle => 'Logo del negocio';

  @override
  String get photosLogoHint => 'Imagen cuadrada, mínimo 400×400 px.';

  @override
  String get photosChangeLogo => 'Cambiar logo';

  @override
  String get photosUploadLogo => 'Subir logo';

  @override
  String get photosCategoryEstablishment => 'Fotos del establecimiento';

  @override
  String get photosCategoryChildrenArea => 'Área infantil';

  @override
  String get photosCategoryMenu => 'Menú';

  @override
  String get photosEmpty => 'Sin fotos';

  @override
  String get photosDeleteTitle => 'Eliminar foto';

  @override
  String get photosDeleteConfirm => '¿Seguro que quieres eliminar esta foto?';

  @override
  String get photosCancel => 'Cancelar';

  @override
  String get photosDelete => 'Eliminar';

  @override
  String get photosErrorUploadLogo => 'No se pudo subir el logo. Intenta de nuevo.';

  @override
  String get photosErrorUploadPhoto => 'No se pudo subir la foto. Intenta de nuevo.';

  @override
  String get photosErrorDeletePhoto => 'No se pudo eliminar la foto. Intenta de nuevo.';

  @override
  String get adminPanelTitle => 'Panel Superadmin';

  @override
  String get adminReload => 'Recargar';

  @override
  String get adminLoadError => 'Error al cargar';

  @override
  String get adminRetry => 'Reintentar';

  @override
  String get adminSectionTitle => 'Administración';

  @override
  String get adminTilePlans => 'Planes de membresía';

  @override
  String adminTilePlansSubtitle(Object count) {
    return '$count planes configurados';
  }

  @override
  String get adminTileOwners => 'Dueños de negocio';

  @override
  String adminTileOwnersSubtitle(Object count) {
    return '$count propietarios registrados';
  }

  @override
  String get adminTileCategories => 'Categorías';

  @override
  String adminTileCategoriesSubtitle(Object count) {
    return '$count categorías · árbol de tipos';
  }

  @override
  String get adminTileCharacteristics => 'Características';

  @override
  String adminTileCharacteristicsSubtitle(Object count) {
    return '$count características';
  }

  @override
  String get adminTileNotifications => 'Notificaciones push';

  @override
  String adminTileNotificationsSubtitle(Object devices, Object sends) {
    return '$devices dispositivos · $sends envíos registrados';
  }

  @override
  String get adminTileAllUsers => 'Todos los usuarios';

  @override
  String get adminTileAllUsersSubtitle => 'Gestionar cuentas · activar / desactivar';

  @override
  String get adminTileAds => 'Publicidad';

  @override
  String get adminTileAdsSubtitle => 'Precios por formato · gestión de campañas';

  @override
  String get adminTileCredits => 'Créditos publicitarios';

  @override
  String get adminTileCreditsSubtitle => 'Asignar saldo a cuentas de establecimientos';

  @override
  String get adminTileBulk => 'Carga masiva de promos';

  @override
  String get adminTileBulkSubtitle => 'Crear promociones para negocios · no cuenta contra el plan';

  @override
  String get adminRoleFilterAll => 'Todos';

  @override
  String get adminRoleFilterUsers => 'Usuarios';

  @override
  String get adminRoleFilterStaff => 'Staff';

  @override
  String get adminRoleFilterOwners => 'Dueños';

  @override
  String get adminRoleFilterAdmin => 'Admin';

  @override
  String adminErrorWithMsg(Object msg) {
    return 'Error: $msg';
  }

  @override
  String get adminAllUsersTitle => 'Todos los usuarios';

  @override
  String get adminSearchNameEmail => 'Buscar por nombre o correo…';

  @override
  String adminUserCount(Object count) {
    return '$count usuario(s)';
  }

  @override
  String get adminNoResults => 'Sin resultados';

  @override
  String get adminAccountDeactivated => 'Cuenta desactivada';

  @override
  String get adminActivate => 'Activar';

  @override
  String get adminDeactivate => 'Desactivar';

  @override
  String get adminActivateAccount => 'Activar cuenta';

  @override
  String get adminDeactivateAccount => 'Desactivar cuenta';

  @override
  String adminActivateAccountConfirm(Object name) {
    return '¿Reactivar la cuenta de $name? Podrá volver a iniciar sesión.';
  }

  @override
  String adminDeactivateAccountConfirm(Object name) {
    return '¿Desactivar la cuenta de $name? No podrá iniciar sesión ni aparecerá su contenido.';
  }

  @override
  String get adminCancel => 'Cancelar';

  @override
  String get adminPlansTitle => 'Planes de membresía';

  @override
  String get adminAddons => 'Add-ons';

  @override
  String get adminAddonsDesc => 'Precios por unidad/mes que se cobran por encima del límite del plan.';

  @override
  String get adminAddonTableMissing => 'Tabla addon_pricing no encontrada.';

  @override
  String get adminAddonRunSql => 'Ejecuta el SQL de add-ons en Supabase primero.';

  @override
  String get adminOwnersTitle => 'Dueños de negocio';

  @override
  String adminResultCount(Object count) {
    return '$count resultado(s)';
  }

  @override
  String get adminCategoriesTitle => 'Categorías';

  @override
  String get adminNewRootType => 'Nuevo tipo raíz';

  @override
  String get adminNoCategories => 'Sin categorías';

  @override
  String get adminLevelType => 'Tipo';

  @override
  String get adminLevelSubtype => 'Subtipo';

  @override
  String get adminLevelSubSubtype => 'Sub-subtipo';

  @override
  String get adminAddSubcategory => 'Agregar subcategoría';

  @override
  String get adminDeleteCategory => 'Eliminar categoría';

  @override
  String adminDeleteCategoryWithChildren(Object name, Object count) {
    return '¿Eliminar \"$name\"? También se eliminarán sus $count subcategoría(s).';
  }

  @override
  String adminDeleteCategorySimple(Object name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get adminDelete => 'Eliminar';

  @override
  String get adminCharacteristicsTitle => 'Características';

  @override
  String get adminNewCharacteristic => 'Nueva característica';

  @override
  String get adminNoCharacteristics => 'Sin características';

  @override
  String get adminDeleteCharacteristic => 'Eliminar característica';

  @override
  String adminDeleteCharacteristicConfirm(Object name) {
    return '¿Eliminar \"$name\"? Se quitará de todos los establecimientos.';
  }

  @override
  String get adminFree => 'Gratis';

  @override
  String adminPricePerMonth(Object price) {
    return '\$$price MXN/mes';
  }

  @override
  String adminBusinessCount(Object count) {
    return '$count negocio(s)';
  }

  @override
  String adminPromoCount(Object count) {
    return '$count promo(s)';
  }

  @override
  String get adminEditPlan => 'Editar plan';

  @override
  String get adminFreeNoCharge => 'Gratis / sin cargo';

  @override
  String get adminEditPrice => 'Editar precio';

  @override
  String adminEditLabel(Object label) {
    return 'Editar: $label';
  }

  @override
  String get adminInvalidPriceMin => 'Ingresa un precio válido (0 o mayor).';

  @override
  String get adminMonthlyPricePerUnit => 'Precio mensual por unidad (MXN)';

  @override
  String get adminNoAdditionalCharge => '0 = sin cargo adicional';

  @override
  String get adminAddonZeroHint => 'Escribe 0 si el add-on es gratuito o aún no está activo.';

  @override
  String get adminSavePrice => 'Guardar precio';

  @override
  String adminEditPlanLabel(Object name) {
    return 'Editar plan: $name';
  }

  @override
  String get adminPriceMxnMonth => 'Precio (MXN/mes)';

  @override
  String get adminZeroForFree => '0 para plan gratuito';

  @override
  String get adminMaxEstablishments => 'Máx. establecimientos';

  @override
  String get adminMaxActivePromos => 'Máx. promociones activas';

  @override
  String get adminSaveChanges => 'Guardar cambios';

  @override
  String adminPlanPickerSubtitle(Object price, Object est, Object promos) {
    return '\$$price MXN/mes · $est neg. · $promos promos';
  }

  @override
  String get adminEdit => 'Editar';

  @override
  String get adminNameEmpty => 'El nombre no puede estar vacío.';

  @override
  String get adminNewCategory => 'Nueva categoría';

  @override
  String get adminEditCategory => 'Editar categoría';

  @override
  String get adminNameRequired => 'Nombre *';

  @override
  String get adminEmojiIcon => 'Emoji / ícono';

  @override
  String get adminBelongsToParent => 'Pertenece a (padre)';

  @override
  String get adminNoParentRoot => '— Sin padre (Tipo raíz) —';

  @override
  String get adminCreateCategory => 'Crear categoría';

  @override
  String get adminEditCharacteristic => 'Editar característica';

  @override
  String get adminCreateCharacteristic => 'Crear característica';

  @override
  String get adminNotificationsTitle => 'Notificaciones push';

  @override
  String get adminTabSend => 'Enviar';

  @override
  String get adminTabScheduled => 'Programadas';

  @override
  String get adminTabHistory => 'Historial';

  @override
  String get adminTabMetrics => 'Métricas';

  @override
  String get adminCompleteTitleBody => 'Completa título y mensaje';

  @override
  String get adminCompleteTitleBodyBeforeSchedule => 'Completa título y mensaje antes de programar';

  @override
  String adminSentResult(Object count) {
    return '✅ Enviada a $count dispositivos';
  }

  @override
  String adminSentResultWithFailed(Object count, Object failed) {
    return '✅ Enviada a $count dispositivos · $failed fallidos';
  }

  @override
  String adminSendErrorResult(Object msg) {
    return '❌ Error: $msg';
  }

  @override
  String get adminScheduledOk => '📅 Notificación programada correctamente';

  @override
  String adminTotalDevices(Object count) {
    return 'Total: $count dispositivos';
  }

  @override
  String get adminTitleRequired => 'Título *';

  @override
  String get adminTitleHint => 'Ej. Nueva función disponible';

  @override
  String get adminMessageRequired => 'Mensaje *';

  @override
  String get adminBodyHint => 'Escribe el cuerpo…';

  @override
  String get adminSegmentRecipients => 'Segmentar destinatarios';

  @override
  String get adminGender => 'Género';

  @override
  String get adminAllGenders => 'Todos los géneros';

  @override
  String get adminAll => 'Todos';

  @override
  String get adminMen => 'Hombres';

  @override
  String get adminWomen => 'Mujeres';

  @override
  String get adminPreferNotToSay => 'Prefieren no decir';

  @override
  String get adminAgeRange => 'Rango de edad';

  @override
  String get adminMin => 'Mín';

  @override
  String get adminMax => 'Máx';

  @override
  String get adminInactiveUsersSince => 'Usuarios inactivos desde hace';

  @override
  String get adminNoFilter => 'No filtrar';

  @override
  String get adminDays7 => '7 días';

  @override
  String get adminDays15 => '15 días';

  @override
  String get adminDays30 => '30 días';

  @override
  String get adminDays60 => '60 días';

  @override
  String get adminDays90Plus => '90 días o más';

  @override
  String get adminPlatform => 'Plataforma';

  @override
  String get adminAllFem => 'Todas';

  @override
  String get adminCalculating => 'Calculando…';

  @override
  String adminRecipientsApprox(Object count) {
    return '~$count destinatarios';
  }

  @override
  String get adminEstimateRecipients => 'Estimar destinatarios';

  @override
  String get adminSchedule => 'Programar';

  @override
  String get adminSending => 'Enviando…';

  @override
  String get adminSendNow => 'Enviar ahora';

  @override
  String get adminNoScheduled => 'Sin notificaciones programadas';

  @override
  String get adminNoScheduledHint => 'Usa la pestaña Enviar → Programar';

  @override
  String adminNextSend(Object date) {
    return 'Próximo: $date';
  }

  @override
  String adminRunCount(Object count) {
    return '$count ejecución(es)';
  }

  @override
  String get adminNoSends => 'Sin envíos registrados.';

  @override
  String get adminTotalSent => 'Total enviados';

  @override
  String get adminAvgDelivery => 'Entrega prom.';

  @override
  String get adminAvgOpen => 'Apertura prom.';

  @override
  String get adminDailySends30 => 'Envíos diarios — últimos 30 días';

  @override
  String get adminLegendSent => 'Enviados';

  @override
  String get adminLegendOpens => 'Aperturas';

  @override
  String get adminNoSendData => 'Sin datos de envíos todavía.';

  @override
  String get adminDevicesByPlatform => 'Dispositivos por plataforma';

  @override
  String get adminLatestNotifications => 'Últimas notificaciones';

  @override
  String get adminColNotification => 'Notificación';

  @override
  String get adminColDelivery => 'Entrega';

  @override
  String get adminColOpen => 'Apertura';

  @override
  String get adminPickDateTime => 'Elige la fecha y hora de envío';

  @override
  String get adminScheduleNotification => 'Programar notificación';

  @override
  String get adminSendDateTime => 'Fecha y hora de envío *';

  @override
  String get adminSelect => 'Seleccionar…';

  @override
  String get adminRepetition => 'Repetición';

  @override
  String get adminOnceOnly => 'Una sola vez';

  @override
  String get adminDaily => 'Diariamente';

  @override
  String get adminWeekly => 'Semanalmente';

  @override
  String get adminMonthly => 'Mensualmente';

  @override
  String get adminDelivered => 'entregados';

  @override
  String get adminFailed => 'fallidos';

  @override
  String get adminOpenStat => 'apertura';

  @override
  String get adminDeliveryStat => 'entrega';

  @override
  String get adminAdsPricesTitle => 'Publicidad · Precios';

  @override
  String get adminNoPriceData => 'Sin datos de precios';

  @override
  String get adminRunAdsSql => 'Ejecuta el SQL de publicidad en Supabase primero.';

  @override
  String get adminPricesByFormat => 'Precios por formato';

  @override
  String adminUsersCount(Object count) {
    return '$count usuarios';
  }

  @override
  String get adminBillingUnitInfo => 'La unidad de cobro (impresiones por precio) se calcula automáticamente según los usuarios activos: crece con la plataforma.';

  @override
  String get adminMinCampaign => 'Mín. campaña';

  @override
  String get adminInvalidPrice => 'Precio inválido';

  @override
  String get adminInvalidMinBudget => 'Presupuesto mínimo inválido';

  @override
  String get adminPricePerThousand => 'Precio por 1 000 impresiones (MXN)';

  @override
  String get adminPricePerSend => 'Precio por envío (MXN)';

  @override
  String get adminFixedRate => 'Tarifa fija (MXN)';

  @override
  String get adminMinCampaignBudget => 'Presupuesto mínimo de campaña (MXN)';

  @override
  String get adminSave => 'Guardar';

  @override
  String get adminCreditsTitle => 'Créditos publicitarios';

  @override
  String get adminSearchEstOwner => 'Buscar establecimiento o dueño…';

  @override
  String get adminBalance => 'saldo';

  @override
  String get adminEnterValidAmount => 'Ingresa un monto válido';

  @override
  String get adminEnterDescription => 'Escribe una descripción';

  @override
  String adminCreditAdded(Object balance) {
    return 'Crédito agregado correctamente. Nuevo saldo: $balance';
  }

  @override
  String adminCurrentBalance(Object balance) {
    return 'Saldo actual: $balance';
  }

  @override
  String get adminAmountToAdd => 'Monto a agregar (MXN)';

  @override
  String get adminDescriptionReason => 'Descripción / motivo';

  @override
  String get adminSaving => 'Guardando…';

  @override
  String get adminAddCredit => 'Agregar crédito';

  @override
  String get adminBulkTitle => 'Carga masiva superadmin';

  @override
  String get adminTabEstablishments => 'Establecimientos';

  @override
  String get adminTabPromotions => 'Promociones';

  @override
  String get adminCsvEmpty => 'El archivo CSV está vacío.';

  @override
  String get adminSelectOwner => 'Selecciona un dueño antes de continuar.';

  @override
  String get adminUploadCsvRow => 'Sube un CSV con al menos una fila de datos.';

  @override
  String adminRowEmptyName(Object row) {
    return 'Fila $row: nombre vacío';
  }

  @override
  String adminRowInvalidDays(Object row) {
    return 'Fila $row: días inválidos (usa 1-7)';
  }

  @override
  String adminRowError(Object row, Object msg) {
    return 'Fila $row: $msg';
  }

  @override
  String adminEstCreated(Object count) {
    return '$count establecimiento(s) creado(s)';
  }

  @override
  String adminPromosCreated(Object count) {
    return '$count promoción(es) creada(s) · no cuentan contra el plan';
  }

  @override
  String adminBulkEstBanner(Object count) {
    return 'Crea establecimientos para cualquier dueño.\nEsta sesión: $count creado(s).';
  }

  @override
  String adminBulkPromoBanner(Object count) {
    return 'Crea promociones para cualquier negocio. No cuentan contra el límite del plan.\nEsta sesión: $count creada(s).';
  }

  @override
  String get adminTemplateEstSubject => 'Plantilla establecimientos Promofy';

  @override
  String get adminTemplatePromoSubject => 'Plantilla promociones Promofy';

  @override
  String get adminDownloadCsvTemplate => 'Descargar plantilla CSV';

  @override
  String get adminOwnerRequired => 'Dueño *';

  @override
  String get adminSelectOwnerHint => 'Selecciona un dueño…';

  @override
  String get adminSelectCsvFile => 'Seleccionar archivo CSV';

  @override
  String adminPreviewRows(Object count) {
    return 'Vista previa ($count fila(s)):';
  }

  @override
  String get adminCreatingEsts => 'Creando establecimientos…';

  @override
  String adminCreateEstsBtn(Object count) {
    return 'Crear $count establecimiento(s)';
  }

  @override
  String get adminSelectEst => 'Selecciona un establecimiento.';

  @override
  String get adminEstRequired => 'Establecimiento *';

  @override
  String get adminSelectBusinessHint => 'Selecciona un negocio…';

  @override
  String get adminCreatingPromos => 'Creando promociones…';

  @override
  String adminCreatePromosBtn(Object count) {
    return 'Crear $count promoción(es)';
  }

  @override
  String get logrosTitle => 'Mis Logros';

  @override
  String get logrosLoadError => 'No se pudieron cargar tus logros.';

  @override
  String get logrosRetry => 'Reintentar';

  @override
  String get logrosSectionVisits => 'Insignias de visitas';

  @override
  String get logrosSectionStreaks => 'Rachas semanales';

  @override
  String logrosNextLevel(Object label) {
    return 'Próximo nivel: $label';
  }

  @override
  String logrosAnnualVisits(Object count) {
    return '$count visitas anuales';
  }

  @override
  String logrosConsecutiveWeeks(Object count) {
    return '$count semanas consecutivas';
  }

  @override
  String logrosVisitsToGo(Object count) {
    return '$count visitas más para alcanzarlo';
  }

  @override
  String get logrosStreakDescEnRacha => 'Visitaste negocios 3 semanas seguidas';

  @override
  String get logrosStreakDescImparable => '8 semanas sin parar — eres imparable';

  @override
  String get logrosStreakDescLeyenda => '26 semanas (medio año) de racha perfecta';

  @override
  String get filterSheetTitle => 'Filtros';

  @override
  String get filterSheetClearAll => 'Limpiar todo';

  @override
  String get filterSheetSectionPlaceFeatures => 'Características del lugar';

  @override
  String get filterSheetSectionCategory => 'Categoría';

  @override
  String get filterSheetSectionFoodType => 'Tipo de comida';

  @override
  String get filterSheetSectionDay => 'Día';

  @override
  String get filterSheetSectionPaymentMethod => 'Método de pago';

  @override
  String get filterSheetApply => 'Aplicar filtros';

  @override
  String filterSheetApplyWithCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'filtros',
      one: 'filtro',
    );
    return 'Aplicar ($count $_temp0)';
  }

  @override
  String get filterChipsActiveNow => 'Activas ahora';

  @override
  String get filterChipsFlash => '⚡ Relámpago';

  @override
  String get filterChipsFavorites => '⭐ Mis favoritas';

  @override
  String get filterChipsBirthday => '🎂 Cumpleañero';

  @override
  String get filterChipsAdvancedMore => 'Más filtros';

  @override
  String filterChipsAdvancedCount(Object count) {
    return 'Filtros ($count)';
  }

  @override
  String get adSplashAdLabel => 'Publicidad';

  @override
  String adSplashPromoSpecial(Object name) {
    return 'Promoción especial de $name';
  }

  @override
  String get adSplashDiscoverMsg => 'Toca para descubrir sus promociones exclusivas';

  @override
  String get adSplashViewPromos => 'Ver promociones';

  @override
  String get sponsoredCardBadge => 'Patrocinado';

  @override
  String get sponsoredCardSeePromotions => 'Ver sus promociones';

  @override
  String get sponsoredCardAd => 'Anuncio';

  @override
  String get adBannerSeePromotions => 'Ver sus promociones';

  @override
  String get adBannerAdLabel => 'Publicidad';

  @override
  String get paymentResultGoHome => 'Ir al inicio';

  @override
  String get paymentResultTryAgain => 'Intentar de nuevo';

  @override
  String get paymentResultSuccessTitle => '¡Pago exitoso!';

  @override
  String get paymentResultSuccessSubtitle => 'Tu saldo de créditos publicitarios se verá\nreflejado en tu panel en unos momentos.';

  @override
  String get paymentResultFailureTitle => 'Pago no completado';

  @override
  String get paymentResultFailureSubtitle => 'No se realizó ningún cargo. Puedes\nintentar de nuevo cuando quieras.';

  @override
  String get paymentResultPendingTitle => 'Pago en proceso';

  @override
  String get paymentResultPendingSubtitle => 'Tu pago está siendo procesado.\nTe notificaremos cuando se confirme.';

  @override
  String get paymentResultSubscriptionTitle => '¡Suscripción activada!';

  @override
  String get paymentResultSubscriptionSubtitle => 'Tu plan Promofy ya está activo.\nDisfruta todas las funciones de tu negocio.';

  @override
  String get locationPermTitle => '¡Las promos te esperan\ncerca de ti!';

  @override
  String get locationPermSubtitle => 'Comparte tu ubicación para ver\nlas mejores promociones ordenadas\npor distancia al instante.';

  @override
  String get locationPermAllowButton => 'Continuar';

  @override
  String get locationPermSkipButton => 'Ahora no';

  @override
  String get splashScrTagline => 'Descubre promociones cerca de ti';

  @override
  String get settingsMyFavs => 'Mis favs';

  @override
  String get tourSkip => 'Saltar';

  @override
  String get tourNext => 'Siguiente';

  @override
  String get tourStart => 'Empezar';

  @override
  String get tourReplay => 'Ver tutorial';

  @override
  String get tour1Title => '¡Bienvenido a Promofy!';

  @override
  String get tour1Desc => 'Descubre las mejores promociones de restaurantes y entretenimiento cerca de ti.';

  @override
  String get tour2Title => 'Explora cerca de ti';

  @override
  String get tour2Desc => 'En Inicio y Lugares encuentras promos y negocios ordenados por distancia. Usa los filtros para hallar justo lo que se te antoja.';

  @override
  String get tour3Title => 'Promos Relámpago';

  @override
  String get tour3Desc => 'Ofertas por tiempo limitado. ¡Aprovéchalas antes de que se acaben!';

  @override
  String get tour4Title => 'Sellos de lealtad';

  @override
  String get tour4Desc => 'Revisa qué negocios tienen programa de lealtad (no todos lo tienen). Muestra tu código QR en cada visita, junta sellos y gana recompensas.';

  @override
  String get tour5Title => 'Favoritos';

  @override
  String get tour5Desc => 'Guarda tus promos favoritas con el corazón y entérate de nuevas promos de tus lugares favoritos.';

  @override
  String get ownerTour1Title => '¡Ya eres negocio Promofy!';

  @override
  String get ownerTour1Desc => 'Administra todo desde la pestaña «Mi negocio»: tus locales, promociones, publicidad y estadísticas.';

  @override
  String get ownerTour2Title => 'Crea promociones';

  @override
  String get ownerTour2Desc => 'Publica promos normales, flash (relámpago) y de cumpleañero para atraer clientes a tu negocio.';

  @override
  String get ownerTour3Title => 'Valida canjes con QR';

  @override
  String get ownerTour3Desc => 'Escanea el código del cliente para validar sus promociones y registrar sus visitas de lealtad.';

  @override
  String get ownerTour4Title => 'Atrae más clientes';

  @override
  String get ownerTour4Desc => 'Crea campañas de publicidad (splash, banner, destacada y notificaciones) para llegar a más gente cerca de ti.';

  @override
  String get ownerTour5Title => 'Mide y crece';

  @override
  String get ownerTour5Desc => 'Revisa tus estadísticas y ticket promedio, y administra tu plan y complementos cuando lo necesites.';

  @override
  String get filterSectionSchedule => 'Horario';

  @override
  String get bandBreakfast => 'Desayuno';

  @override
  String get bandLunch => 'Comida';

  @override
  String get bandDinner => 'Cena';

  @override
  String get bandLateNight => 'Madrugada';

  @override
  String get visitasOwnerLoyaltyTitle => 'Programa de lealtad';

  @override
  String get visitasOwnerLoyaltySubtitle => 'Escanea el QR de tus clientes para sumar sellos';

  @override
  String get visitasPickEstablishment => 'Elige el establecimiento';

  @override
  String get visitasNoEstablishments => 'No tienes establecimientos';

  @override
  String get ownerTour6Title => 'Lealtad: tu arma para crecer';

  @override
  String get ownerTour6Desc => 'Tu programa de sellos hace que los clientes REGRESEN por su recompensa: más visitas y más clientes nuevos por recomendación.';

  @override
  String get ownerTour6Note => '📈 Los socios de lealtad visitan ~20% más seguido y gastan ~20% más por visita (Circana).\n🔁 Captar un cliente nuevo cuesta de 5 a 25× más que retener uno (Harvard Business Review).';
}
