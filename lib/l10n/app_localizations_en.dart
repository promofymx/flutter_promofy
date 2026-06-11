import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageAuto => 'Automatic (device)';

  @override
  String get retry => 'Retry';

  @override
  String get explore => 'Explore';

  @override
  String get favTitle => 'My favorites';

  @override
  String get favTabPromos => 'Promotions';

  @override
  String get favTabEstablishments => 'Places';

  @override
  String get favEmptyPromosTitle => 'You don\'t have favorite promos yet';

  @override
  String get favEmptyPromosSubtitle => 'Tap the heart on any promo\nto save it here';

  @override
  String get favEmptyEstTitle => 'You don\'t have favorite places yet';

  @override
  String get favEmptyEstSubtitle => 'Open a place and tap the heart\nto save it here';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get loginWelcome => 'Welcome to Promofy';

  @override
  String get loginSubtitle => 'Discover deals near you';

  @override
  String get loginContinueGoogle => 'Continue with Google';

  @override
  String get loginOr => 'or';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailEmpty => 'Enter your email';

  @override
  String get loginEmailInvalid => 'Invalid email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordEmpty => 'Enter your password';

  @override
  String get loginPasswordMinLength => 'At least 6 characters';

  @override
  String get loginReferralLabel => 'Invitation code (optional)';

  @override
  String get loginForgotPassword => 'Forgot your password?';

  @override
  String get loginSignInButton => 'Sign in';

  @override
  String get loginSignUpButton => 'Create account';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginHaveAccount => 'Already have an account? ';

  @override
  String get loginSignUpLink => 'Sign up';

  @override
  String get loginSignInLink => 'Sign in';

  @override
  String get loginGuestButton => 'Explore without an account';

  @override
  String get loginResetInvalidEmail => 'Enter a valid email.';

  @override
  String get loginResetTitle => 'Reset password';

  @override
  String get loginResetDone => 'Done';

  @override
  String get loginResetCancel => 'Cancel';

  @override
  String get loginResetSend => 'Send';

  @override
  String get loginResetDescription => 'We\'ll send you a link to reset your password.';

  @override
  String get loginResetEmailHint => 'you@email.com';

  @override
  String get loginResetSuccessTitle => 'Email sent!';

  @override
  String get loginResetSuccessBody => 'Check your inbox and follow the instructions.';

  @override
  String get loginResetSpamHint => 'If it doesn\'t arrive in a few minutes, check your spam folder.';

  @override
  String get onboardingTitle => 'Complete your profile';

  @override
  String get onboardingExit => 'Exit';

  @override
  String get onboardingHeading => 'Tell us about yourself';

  @override
  String get onboardingAdultOnlyNotice => 'Promofy is only for users over 18';

  @override
  String get onboardingNameQuestion => 'What is your name?';

  @override
  String get onboardingNameHint => 'Your full name';

  @override
  String get onboardingNameRequired => 'Enter your name';

  @override
  String get onboardingBirthQuestion => 'When were you born?';

  @override
  String get onboardingSelectBirthDate => 'Select your date of birth';

  @override
  String get onboardingGenderQuestion => 'What is your gender?';

  @override
  String get onboardingGenderMale => 'Male';

  @override
  String get onboardingGenderFemale => 'Female';

  @override
  String get onboardingGenderPreferNot => 'Prefer not to say';

  @override
  String get onboardingSubmit => 'Complete my profile';

  @override
  String get onboardingMustBeAdult => 'You must be over 18';

  @override
  String get onboardingConfirm => 'Confirm';

  @override
  String get onboardingCancel => 'Cancel';

  @override
  String get onboardingMustBeAdultToUse => 'You must be over 18 to use Promofy';

  @override
  String get onboardingSelectGender => 'Select your gender';

  @override
  String get resetPwdAppBarTitle => 'New password';

  @override
  String get resetPwdUpdateError => 'The password could not be updated.';

  @override
  String get resetPwdSuccessTitle => 'Password updated!';

  @override
  String get resetPwdSuccessSubtitle => 'You can now sign in\nwith your new password.';

  @override
  String get resetPwdGoHome => 'Go to home';

  @override
  String get resetPwdFormTitle => 'Create your new password';

  @override
  String get resetPwdFormHint => 'It must be at least 6 characters long.';

  @override
  String get resetPwdNewLabel => 'New password';

  @override
  String get resetPwdMinLength => 'Minimum 6 characters';

  @override
  String get resetPwdConfirmLabel => 'Confirm password';

  @override
  String get resetPwdMismatch => 'The passwords do not match';

  @override
  String get resetPwdSave => 'Save password';

  @override
  String get homeSearchHint => 'Search for a promo or restaurant...';

  @override
  String homeEmptySearch(Object query) {
    return 'No results for \"$query\"';
  }

  @override
  String get homeEmptyFilters => 'No results for these filters';

  @override
  String get homeEmptyNoPromos => 'No promotions here yet';

  @override
  String get homeClearSearchAndFilters => 'Clear search and filters';

  @override
  String get homeRetry => 'Retry';

  @override
  String get promoDetailNew => 'New';

  @override
  String get promoDetailBirthdayGift => 'Your birthday gift';

  @override
  String promoDetailConditions(Object terms) {
    return 'Conditions: $terms';
  }

  @override
  String get promoDetailDescription => 'Description';

  @override
  String get promoDetailAvailability => 'Availability';

  @override
  String get promoDetailShare => 'Share';

  @override
  String get promoDetailSaved => 'Saved';

  @override
  String get promoDetailSave => 'Save';

  @override
  String get promoDetailFlash => '⚡ Flash';

  @override
  String promoDetailFlashEndsInHours(Object hours, Object minutes) {
    return '⚡ Ends in ${hours}h ${minutes}m';
  }

  @override
  String promoDetailFlashEndsInMinutes(Object minutes) {
    return '⚡ Ends in ${minutes}m';
  }

  @override
  String get restaurantNew => 'New';

  @override
  String get restaurantTypeUrbanMobile => 'Urban / Mobile';

  @override
  String get restaurantTypeLocal => 'Storefront';

  @override
  String get restaurantCall => 'Call';

  @override
  String get restaurantWebsite => 'Website';

  @override
  String get restaurantCharacteristics => 'Features';

  @override
  String get restaurantPaymentMethods => 'Payment methods';

  @override
  String get restaurantSchedule => 'Hours';

  @override
  String get restaurantClosed => 'Closed';

  @override
  String get restaurantLocation => 'Location';

  @override
  String get restaurantViewOnMap => 'View on map';

  @override
  String get restaurantGetDirections => 'Directions';

  @override
  String get restaurantPhotos => 'Photos';

  @override
  String get restaurantLoyaltyProgram => 'Loyalty program';

  @override
  String restaurantVisitsCount(Object count) {
    return '$count visits';
  }

  @override
  String restaurantValidUntil(Object date, Object days) {
    return 'Valid until $date · $days days';
  }

  @override
  String restaurantEnded(Object date) {
    return 'Ended $date';
  }

  @override
  String get restaurantViewStampsAndQr => 'View my stamps and QR';

  @override
  String get restaurantActivePromos => 'Active promotions';

  @override
  String get restaurantNoActivePromos => 'No active promotions for now.';

  @override
  String get restaurantNoPromosToday => 'No promotions for today.';

  @override
  String get restaurantAlsoThisWeek => 'Also this week';

  @override
  String get restaurantFlash => 'Flash';

  @override
  String get restaurantRetry => 'Retry';

  @override
  String get lugaresSearchHint => 'Search business...';

  @override
  String get lugaresChipOpenNow => 'Open now';

  @override
  String get lugaresChipFlash => '⚡ Flash';

  @override
  String get lugaresChipFavorites => '⭐ My favorites';

  @override
  String get lugaresChipMoreFilters => 'More filters';

  @override
  String lugaresChipFiltersCount(Object count) {
    return 'Filters ($count)';
  }

  @override
  String get lugaresFiltersTitle => 'Filters';

  @override
  String get lugaresClearAll => 'Clear all';

  @override
  String get lugaresSectionCharacteristics => 'Place features';

  @override
  String get lugaresSectionCategory => 'Category';

  @override
  String get lugaresSectionDay => 'Day';

  @override
  String get lugaresSectionPayment => 'Payment method';

  @override
  String get lugaresDayMon => 'Mon';

  @override
  String get lugaresDayTue => 'Tue';

  @override
  String get lugaresDayWed => 'Wed';

  @override
  String get lugaresDayThu => 'Thu';

  @override
  String get lugaresDayFri => 'Fri';

  @override
  String get lugaresDaySat => 'Sat';

  @override
  String get lugaresDaySun => 'Sun';

  @override
  String get lugaresPaymentCash => 'Cash';

  @override
  String get lugaresPaymentCard => 'Card';

  @override
  String get lugaresPaymentTransfer => 'Transfer';

  @override
  String get lugaresPaymentMercadopago => 'MercadoPago';

  @override
  String lugaresApplyWithCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'filters',
      one: 'filter',
    );
    return 'Apply ($count $_temp0)';
  }

  @override
  String get lugaresApplyFilters => 'Apply filters';

  @override
  String get lugaresEmptyFiltered => 'No results for the applied filters';

  @override
  String get lugaresEmptyNoNearby => 'No businesses nearby for now';

  @override
  String get lugaresClearFilters => 'Clear filters';

  @override
  String get lugaresRetry => 'Retry';

  @override
  String get stampsTitle => 'My Stamps';

  @override
  String get stampsMyQrTooltip => 'My visits QR';

  @override
  String get stampsSectionReady => 'Rewards ready to redeem';

  @override
  String get stampsSectionInProgress => 'In progress';

  @override
  String get stampsSuffixProgram => 'program';

  @override
  String get stampsSuffixPrograms => 'programs';

  @override
  String get stampsSectionEarned => 'Earned rewards';

  @override
  String get stampsSuffixTotal => 'total';

  @override
  String get stampsSeeAllRewards => 'See all rewards →';

  @override
  String get stampsTapForRedemptionQr => 'Tap to view redemption QR';

  @override
  String get stampsReadyBadge => 'READY!';

  @override
  String get stampsFinished => 'Finished';

  @override
  String stampsVisitsCount(Object visits, Object required) {
    return '$visits/$required visits';
  }

  @override
  String stampsStampsLeft(Object count) {
    return '$count to go! 🔥';
  }

  @override
  String stampsExpiredOn(Object date) {
    return 'Expired on $date';
  }

  @override
  String stampsExpiresOn(Object date) {
    return 'Expires on $date';
  }

  @override
  String get stampsRedeemed => 'Redeemed';

  @override
  String get stampsRedeemReward => 'Redeem reward';

  @override
  String stampsAtEstablishment(Object name) {
    return 'at $name';
  }

  @override
  String stampsCodeLabel(Object code) {
    return 'Code: $code';
  }

  @override
  String get stampsShowCodeToStaff => 'Show this code to the staff';

  @override
  String get stampsStaffWillScan => 'They will scan it to validate your reward';

  @override
  String get stampsMyQrTitle => 'My QR code';

  @override
  String get stampsMyQrSubtitle => 'Show this code to the business to register your visit.';

  @override
  String get stampsUniqueAccountCode => 'Your unique account code';

  @override
  String get stampsRetry => 'Retry';

  @override
  String get stampsEmptyTitle => 'You don\'t have any stamps yet';

  @override
  String get stampsEmptyMsg => 'Visit businesses with a loyalty program and show them your QR code to collect stamps.';

  @override
  String get stampsViewMyQr => 'View my QR';

  @override
  String get loyaltyTitle => 'Loyalty program';

  @override
  String get loyaltyScan => 'Scan';

  @override
  String get loyaltyStatusDeactivated => 'Deactivated';

  @override
  String loyaltyStatusExpired(Object date) {
    return 'Expired on $date';
  }

  @override
  String loyaltyStatusExpiresIn(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expires in $days days',
      one: 'Expires in $days day',
    );
    return '$_temp0';
  }

  @override
  String loyaltyStatusActive(Object date) {
    return 'Active — ends $date';
  }

  @override
  String get loyaltyVisitsRequired => 'Visits required';

  @override
  String get loyaltyReward => 'Reward';

  @override
  String get loyaltyStart => 'Start';

  @override
  String get loyaltyEnd => 'End';

  @override
  String get loyaltyEndNow => 'End program now';

  @override
  String get loyaltyCreateNew => 'Create new program';

  @override
  String get loyaltyEndDialogTitle => 'End program?';

  @override
  String get loyaltyEndDialogContent => 'All customers will stop accumulating visits in this program. You can create a new one whenever you want.';

  @override
  String get loyaltyCancel => 'Cancel';

  @override
  String get loyaltyEnd2 => 'End';

  @override
  String get loyaltyNoProgramDesc => 'Build customer loyalty with a digital stamp system. Set how many visits they need to earn their reward.';

  @override
  String get loyaltyCreate => 'Create program';

  @override
  String get loyaltyParticipants => 'Participants';

  @override
  String get loyaltyRewardWon => 'Reward earned';

  @override
  String get loyaltyViewClients => 'View customers';

  @override
  String get loyaltyClientsTitle => 'My clients';

  @override
  String get loyaltyClientsLoadError => 'Couldn\'t load clients.';

  @override
  String get loyaltyClientsRetry => 'Retry';

  @override
  String get loyaltyClientsCurrentProgram => 'CURRENT PROGRAM';

  @override
  String loyaltyClientsParticipants(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants',
      one: '$count participant',
    );
    return '$_temp0';
  }

  @override
  String get loyaltyClientsEmptyProgram => 'No clients in this program yet. Scan the QR code of your first visitors.';

  @override
  String get loyaltyClientsReward => 'Reward!';

  @override
  String loyaltyClientsStampsLeft(Object count) {
    return '$count until reward';
  }

  @override
  String get loyaltyClientsHistoryHeader => 'DINER HISTORY';

  @override
  String get loyaltyClientsHistorySubtitle => 'Total visits recorded via QR, highest to lowest.';

  @override
  String get loyaltyClientsEmptyHistory => 'History will appear here as you scan your clients with QR.';

  @override
  String get loyaltyClientsColumnClient => 'Client';

  @override
  String get loyaltyClientsColumnVisits => 'Visits';

  @override
  String get loyaltyClientsColumnSpent => 'Spent';

  @override
  String get loyaltyClientsColumnLast => 'Last';

  @override
  String get qrInvalidCode => 'Invalid QR. Ask the customer to show their code.';

  @override
  String get qrScanTitle => 'Scan customer';

  @override
  String get qrTorch => 'Flashlight';

  @override
  String get qrPointInstruction => 'Point at the customer\'s QR';

  @override
  String get qrErrorUnauthorized => 'You don\'t have permission to record visits in this program.';

  @override
  String get qrErrorProgramInactive => 'The program is inactive or has expired.';

  @override
  String get qrErrorNetwork => 'Connection error. Please try again.';

  @override
  String get qrErrorUnexpected => 'An unexpected error occurred.';

  @override
  String get qrErrorMinTicket => 'The purchase doesn\'t meet the program\'s minimum.';

  @override
  String get qrErrorAlreadyToday => 'This customer already earned a stamp today.';

  @override
  String get qrErrorTooSoon => 'Can\'t add another stamp yet. Try again later.';

  @override
  String get qrErrorRewardExpired => 'The reward has expired.';

  @override
  String get qrTicketAmountTitle => 'Purchase amount';

  @override
  String get qrTicketCancel => 'Cancel';

  @override
  String get qrTicketConfirm => 'Register';

  @override
  String qrMinTicketHint(Object amount) {
    return 'Minimum purchase to earn a stamp: \$$amount';
  }

  @override
  String qrMinTicketError(Object amount) {
    return 'The purchase must be at least \$$amount.';
  }

  @override
  String get loyaltyRulesTitle => 'Rules (optional)';

  @override
  String get loyaltyRulesSubtitle => 'Enable only what you need. Leave blank or 0 to turn a rule off.';

  @override
  String get loyaltyRuleOnePerDay => 'Max 1 stamp per day per customer';

  @override
  String get loyaltyRuleMinTicket => 'Minimum purchase to earn a stamp';

  @override
  String get loyaltyRuleMinHours => 'Minimum time between stamps';

  @override
  String get loyaltyRuleStampValidity => 'Validity of in-progress stamps';

  @override
  String get loyaltyRuleRewardValidity => 'Reward validity';

  @override
  String get loyaltyRuleOffHint => '0 = no limit';

  @override
  String get loyaltyRuleHoursSuffix => 'hours';

  @override
  String get loyaltyRuleDaysSuffix => 'days';

  @override
  String get qrCouldNotRegister => 'Could not register';

  @override
  String get qrRewardWonTitle => 'Reward won! 🎉';

  @override
  String qrRewardWonMessage(Object visits) {
    return 'The customer completed $visits visits. It\'s time to give them their gift!';
  }

  @override
  String get qrVisitRegistered => 'Visit recorded';

  @override
  String qrVisitsLeft(Object count) {
    return 'The customer needs $count more visit(s) to earn their reward.';
  }

  @override
  String get qrProgramCompleted => 'They completed the program!';

  @override
  String get qrBillAmountLabel => 'Bill amount (optional)';

  @override
  String get qrBillAmountHint => 'e.g. 350';

  @override
  String get qrBillAmountHelper => 'Record how much the customer spent to measure Promofy\'s ROI.';

  @override
  String get qrDone => 'Done';

  @override
  String qrVisitsCount(Object current, Object total) {
    return '$current/$total visits';
  }

  @override
  String get loyaltyFormTitle => 'New loyalty program';

  @override
  String get loyaltyFormInfo => 'The customer shows their QR code and you scan it on each visit. Once they reach the required number of visits, they receive their reward. When the program ends you can create a new one and all counters reset.';

  @override
  String get loyaltyFormVisitsLabel => 'Visits to earn the reward';

  @override
  String get loyaltyFormVisitsHint => 'E.g. 5';

  @override
  String get loyaltyFormVisitsSuffix => 'visits';

  @override
  String get loyaltyFormVisitsMin => 'Minimum 2 visits';

  @override
  String get loyaltyFormVisitsMax => 'Maximum 50 visits';

  @override
  String get loyaltyFormRewardLabel => 'What does the customer get?';

  @override
  String get loyaltyFormRewardHint => 'E.g. Free coffee, 20% off, free dessert…';

  @override
  String get loyaltyFormRewardRequired => 'Describe the reward';

  @override
  String get loyaltyFormValidityLabel => 'Program validity';

  @override
  String get loyaltyFormStartLabel => 'Start';

  @override
  String get loyaltyFormEndLabel => 'End';

  @override
  String get loyaltyFormSelectDate => 'Select';

  @override
  String get loyaltyFormSaving => 'Saving…';

  @override
  String get loyaltyFormSubmit => 'Activate program';

  @override
  String get loyaltyFormSelectEndDate => 'Select the program\'s end date.';

  @override
  String get loyaltyFormCreateError => 'Failed to create the program. Please try again.';

  @override
  String get plansWebviewSubscriptionTitle => 'Promofy Subscription';

  @override
  String get plansWebviewAddonTitle => 'Buy add-on';

  @override
  String get plansAppBarTitle => 'Plans & payments';

  @override
  String get plansRetry => 'Retry';

  @override
  String get plansPaymentApprovedTitle => 'Payment approved!';

  @override
  String get plansPaymentPendingTitle => 'Payment in progress';

  @override
  String get plansPaymentApprovedBody => 'Your subscription was activated successfully. You can now enjoy all the benefits of your plan.';

  @override
  String get plansPaymentPendingBody => 'Your payment is being processed. As soon as it is confirmed, your plan will update automatically.';

  @override
  String get plansGotIt => 'Got it';

  @override
  String get plansLaunchPromoTitle => 'Launch Promotion';

  @override
  String get plansLaunchPromoSubtitle => 'From \$99 MXN. The value of your plan comes back to you as advertising credits.';

  @override
  String get plansLaunchPromoValidUntil => 'Valid until July 18, 2026';

  @override
  String get plansActivePlanFallback => 'Active plan';

  @override
  String get plansNoActivePlan => 'No active plan';

  @override
  String get plansCurrentPlanLabel => 'Your current plan';

  @override
  String get plansActiveBadge => 'Active';

  @override
  String get plansCurrentBadge => 'Current';

  @override
  String plansPricePerMonth(Object amount) {
    return '\$$amount MXN/month';
  }

  @override
  String get plansFree => 'Free';

  @override
  String get plansMxnPerMonthSuffix => ' MXN/month';

  @override
  String plansAdCredit(Object amount) {
    return '+\$$amount in advertising';
  }

  @override
  String plansFeatureEstablishments(Object count) {
    return '$count establishment(s)';
  }

  @override
  String plansFeaturePromotions(Object count) {
    return '$count active standard promotions';
  }

  @override
  String get plansFeatureFlashSingle => '1 flash promo per month';

  @override
  String get plansFeatureFlashMulti => '1 flash promo/month per establishment';

  @override
  String get plansFeatureBirthdaySingle => 'Birthday promo';

  @override
  String get plansFeatureBirthdayMulti => 'Birthday promo per establishment';

  @override
  String get plansFeatureLoyaltySingle => 'Loyalty program';

  @override
  String get plansFeatureLoyaltyMulti => 'Loyalty program per establishment';

  @override
  String get plansFeatureStats => 'Real-time statistics';

  @override
  String plansFeaturePush(Object count) {
    return '$count push notifications/month';
  }

  @override
  String get plansActivePlanButton => 'Active plan';

  @override
  String get plansProcessing => 'Processing...';

  @override
  String get plansSubscribe => 'Subscribe';

  @override
  String get plansHaveDiscountQuestion => 'Have a discount code?';

  @override
  String get plansDiscountHint => 'Code (optional)';

  @override
  String get plansApplyCode => 'Apply';

  @override
  String get plansContinuePayment => 'Continue to payment';

  @override
  String get plansCancel => 'Cancel';

  @override
  String get plansDiscountInvalid => 'Invalid or unavailable code.';

  @override
  String get plansDiscountAlreadyUsed => 'You already used this code.';

  @override
  String get plansDiscountPerMonth => '/mo';

  @override
  String get plansDiscountFreeMonthsLabel => 'months free';

  @override
  String get plansDiscountThen => 'then';

  @override
  String get plansAddonsLabel => 'ADD-ONS';

  @override
  String get plansAddonsDescription => 'Expand your plan with monthly add-ons. They are billed every month and you can cancel anytime.';

  @override
  String get plansAddonEstablishmentTitle => '1 additional establishment';

  @override
  String get plansAddonEstablishmentDesc => 'An extra venue on your account. Billed every month until you cancel it.';

  @override
  String get plansAddonEstablishmentPrice => '\$199 MXN/month';

  @override
  String get plansAddonPromotionTitle => '1 additional promotion';

  @override
  String get plansAddonPromotionDesc => 'An extra promotion at any venue. Billed every month until you cancel it.';

  @override
  String get plansAddonPromotionPrice => '\$49 MXN/month';

  @override
  String get plansBuy => 'Buy';

  @override
  String get plansActiveAddonsTitle => 'My active add-ons';

  @override
  String get plansActiveAddonsSubtitle => 'They renew every month. Cancel anytime.';

  @override
  String get plansAddonPromotionLabel => 'Additional promotion';

  @override
  String get plansAddonEstablishmentLabel => 'Additional establishment';

  @override
  String get plansCancelAddonTitle => 'Cancel add-on';

  @override
  String plansCancelAddonConfirm(Object label) {
    return 'Cancel \"$label\"? It will stop being billed next month.';
  }

  @override
  String plansCancelAddonConfirmWithPromos(Object count, Object label) {
    return '$count promotion(s) will be deactivated and \"$label\" will be cancelled. Continue?';
  }

  @override
  String get plansNo => 'No';

  @override
  String get plansYesCancel => 'Yes, cancel';

  @override
  String get plansAddonCancelled => 'Add-on cancelled.';

  @override
  String get plansCancelError => 'Could not cancel. Please try again.';

  @override
  String plansDeactivateDialogTitle(Object count) {
    return 'Deactivate $count promotion(s)';
  }

  @override
  String plansDeactivateDialogBody(Object count) {
    return 'Cancelling this add-on puts you over your limit. Choose $count to deactivate:';
  }

  @override
  String get plansPromoFallback => 'Promo';

  @override
  String get plansContinue => 'Continue';

  @override
  String get paymentSecureTitle => 'Secure payment';

  @override
  String get paymentOpeningBrowser => 'Opening MercadoPago in your browser...';

  @override
  String get paymentCancelTooltip => 'Cancel payment';

  @override
  String get profileTitle => 'My profile';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileNoName => 'No name';

  @override
  String get profileBusinessOwnerChip => 'Business owner';

  @override
  String get profileLevelBusinessActive => 'Active business';

  @override
  String get profileLevelStaff => 'Employee';

  @override
  String get profileAccountInfoTitle => 'Account information';

  @override
  String get profileFieldName => 'Name';

  @override
  String get profileFieldBirthDate => 'Date of birth';

  @override
  String get profileFieldGender => 'Gender';

  @override
  String get profileGenderMale => 'Male';

  @override
  String get profileGenderFemale => 'Female';

  @override
  String get profileGenderOther => 'Other';

  @override
  String get profileBusinessMembershipTitle => 'Business membership';

  @override
  String get profileGoToMyBusiness => 'Go to My business';

  @override
  String get profileViewPlansAndPayments => 'View plans and payments';

  @override
  String get profileBasicPlan => 'Basic plan';

  @override
  String get profileNoExpiry => 'No expiry';

  @override
  String profileExpired(Object date) {
    return 'Expired ($date)';
  }

  @override
  String profileExpiresOn(Object date) {
    return 'Expires on $date';
  }

  @override
  String get profileHaveBusinessTitle => 'Do you have a business?';

  @override
  String get profileHaveBusinessSubtitle => 'Register it and reach more customers';

  @override
  String get profileRegisterIt => 'Register it';

  @override
  String get profileSheetTitleLoaded => 'It\'s already on Promofy';

  @override
  String get profileSheetTitleCode => 'Enter your code';

  @override
  String get profileSheetTitleNoCode => 'Find your business';

  @override
  String get profileSheetTitleInitial => 'Register your business';

  @override
  String get profileOptionNewTitle => 'It\'s new';

  @override
  String get profileOptionNewSubtitle => 'I want to register my business on Promofy';

  @override
  String get profileOptionLoadedTitle => 'It\'s already listed';

  @override
  String get profileOptionLoadedSubtitle => 'My business already exists on Promofy';

  @override
  String get profileOptionHaveCodeTitle => 'I have a code';

  @override
  String get profileOptionHaveCodeSubtitle => 'Enter my invitation code';

  @override
  String get profileOptionNoCodeTitle => 'I don\'t have a code';

  @override
  String get profileOptionNoCodeSubtitle => 'Search my business by name and address';

  @override
  String get profileEnterInvitationCode => 'Enter your invitation code.';

  @override
  String get profileInvalidCode => 'Invalid code.';

  @override
  String get profileConnectionError => 'Connection error.';

  @override
  String get profileInvitationCodeHint => 'INVITATION CODE';

  @override
  String get profileVerifyCode => 'Verify code';

  @override
  String get profileValidCode => 'Valid code!';

  @override
  String get profileEstablishmentFound => 'Establishment found';

  @override
  String get profileChooseMyPlan => 'Choose my plan';

  @override
  String get profileBusinessNameHint => 'Your business name';

  @override
  String get profileAddressHint => 'Address (street, number, neighborhood…)';

  @override
  String get profileEnterBusinessName => 'Enter your business name.';

  @override
  String get profileSearchError => 'Search error. Please try again.';

  @override
  String get profileSearchMyBusiness => 'Search my business';

  @override
  String get profileNoMatches => 'We found no matches.\nCheck the name or address.';

  @override
  String get profileSelectYourBusiness => 'Select your business:';

  @override
  String get profileYourBusiness => 'Your business';

  @override
  String get profileAddressMatchQuestion => 'We verified the address matches. Is this your business?';

  @override
  String get profileYesItsMineChoosePlan => 'Yes, it\'s mine — Choose plan';

  @override
  String get profileNotThisBusiness => 'Not this business';

  @override
  String get profileBack => 'Back';

  @override
  String get profileFavoritesTitle => 'My favorites';

  @override
  String get profileFavoritesSubtitle => 'Promos and businesses you saved';

  @override
  String get profileSettingsTitle => 'Settings';

  @override
  String get profileSettingsSubtitle => 'Name, radius, preferences, password and account';

  @override
  String get profileWorkplacesTitle => 'My workplaces';

  @override
  String get profileNoWorkplaces => 'No associated establishments found.';

  @override
  String get profileRoleManager => 'Manager';

  @override
  String get profileRoleCashierWaiter => 'Cashier / Waiter';

  @override
  String get profileRoleCashier => 'Cashier';

  @override
  String get profileRoleCustom => 'Custom';

  @override
  String profileRoleLabel(Object role) {
    return 'Role: $role';
  }

  @override
  String get profilePermLoyaltyQr => 'Loyalty QR';

  @override
  String get profilePermStats => 'Statistics';

  @override
  String get profilePermPromos => 'Promos';

  @override
  String get profileWorkAtBusinessTitle => 'Do you work at a business?';

  @override
  String get profileWorkAtBusinessSubtitle => 'Enter your invitation code';

  @override
  String get profileJoin => 'Join';

  @override
  String get profileLinkCopied => 'Link copied to clipboard!';

  @override
  String profileReferralShareText(Object url) {
    return 'Join Promofy and attract more customers to your business!\nCreate your account with my link and we both win:\n$url';
  }

  @override
  String get profileReferralShareSubject => 'Join Promofy';

  @override
  String get profileReferralTitle => 'Referral program';

  @override
  String get profileReferralDescription => 'Invite other businesses with your link. When they activate a paid membership, you get \$300 MXN in advertising credits.';

  @override
  String get profileCreditsEarned => 'Credits earned';

  @override
  String get profileCopied => 'Copied';

  @override
  String get profileCopyLink => 'Copy link';

  @override
  String get profileShare => 'Share';

  @override
  String get profileReferralLinkSoon => 'Your referral link will be available shortly.';

  @override
  String get profileReferralHaveCodeTitle => 'Were you invited?';

  @override
  String get profileReferralCodeHint => 'Invitation code';

  @override
  String get profileReferralApply => 'Apply';

  @override
  String get profileReferralOk => 'Code applied! 🎉';

  @override
  String get profileReferralAlready => 'You already had an invitation code registered.';

  @override
  String get profileReferralNotFound => 'Invalid code.';

  @override
  String get profileReferralSelf => 'You can\'t use your own code.';

  @override
  String get profileReferralGenericError => 'Couldn\'t apply the code.';

  @override
  String get profileAchievementsTitle => 'My Achievements';

  @override
  String get profileSeeAll => 'See all';

  @override
  String profileVisitsToNextBadge(Object visits, Object toGo, Object nextBadge) {
    return '$visits visits · $toGo more to reach $nextBadge';
  }

  @override
  String profileVisitsMaxLevel(Object visits) {
    return '$visits visits this year — top level!';
  }

  @override
  String profileStreakWeeks(Object weeks) {
    return '$weeks wk. streak';
  }

  @override
  String profileTopInCity(Object percent) {
    return 'Top $percent% in your city';
  }

  @override
  String get profileWelcomeToTeam => 'Welcome to the team!';

  @override
  String get profileJoinATeam => 'Join a team';

  @override
  String get profileContinue => 'Continue';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileJoinMe => 'Join';

  @override
  String get profileCodeSixChars => 'The code must be 6 characters.';

  @override
  String get profileCodeInvalidOrExpired => 'Invalid or expired code.';

  @override
  String get profileConnectionErrorRetry => 'Connection error. Please try again.';

  @override
  String get profileEnterSixCharCode => 'Enter the 6-character code the administrator shared with you.';

  @override
  String get profileWillUpdateOnContinue => 'Your profile will update when you continue.';

  @override
  String get settingsName => 'Name';

  @override
  String get settingsPersonalizePrompt => '✨ Complete your date of birth and gender for personalized deals.';

  @override
  String get settingsNameHint => 'Your full name';

  @override
  String get settingsNameEmpty => 'The name cannot be empty.';

  @override
  String get settingsSearchRadius => 'Search radius';

  @override
  String get settingsPreferredTypes => 'Preferred place types';

  @override
  String get settingsFavoriteFood => 'Favorite food';

  @override
  String get settingsLoadingCategories => 'Loading categories…';

  @override
  String get settingsSaveButton => 'Save settings';

  @override
  String get settingsSaved => 'Settings saved.';

  @override
  String get settingsSaveError => 'Error saving. Please try again.';

  @override
  String get settingsAccountSecurity => 'Account and security';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsNewPassword => 'New password';

  @override
  String get settingsConfirmPassword => 'Confirm password';

  @override
  String get settingsPasswordMin => 'Minimum 6 characters';

  @override
  String get settingsPasswordMismatch => 'They do not match';

  @override
  String get settingsPasswordUpdated => 'Password updated.';

  @override
  String get settingsPasswordError => 'Could not change the password. Please try again.';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsSave => 'Save';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteConfirmTitle => 'Are you sure?';

  @override
  String get settingsDeleteConfirmBody => 'You will lose all your information: your profile, favorites, loyalty stamps, history and, if you have a business, its associated data.\n\nThis action is permanent and cannot be undone.';

  @override
  String settingsDeleteError(Object email) {
    return 'The account could not be deleted. Write to us at $email';
  }

  @override
  String get bizMyBusiness => 'My business';

  @override
  String get bizEditInfo => 'Edit information';

  @override
  String bizPromoLimitReached(Object max) {
    return 'You reached your limit of $max promotions. Buy extra space or upgrade your plan to add more.';
  }

  @override
  String bizEstablishmentLimitReached(Object plan, Object max) {
    return 'Your \"$plan\" plan allows up to $max establishments. Upgrade your plan to add more.';
  }

  @override
  String get bizStatsTitle => 'Your business statistics';

  @override
  String get bizStatsGateDesc => 'Activate a plan to see impressions, favorites and the demographics of your audience.';

  @override
  String get bizViewPlans => 'View plans';

  @override
  String get bizUsageBusinesses => 'biz.';

  @override
  String get bizUsagePromos => 'promos';

  @override
  String get bizUpgrade => 'Upgrade ↗';

  @override
  String get bizAdd => 'Add';

  @override
  String get bizBusinessInfo => 'Business information';

  @override
  String get bizNoExtraInfo => 'No additional information.';

  @override
  String get bizTypeLocal => 'Storefront';

  @override
  String get bizTypeUrbanMobile => 'Urban / Mobile';

  @override
  String get bizPaymentCard => 'Credit/debit card';

  @override
  String get bizPaymentCash => 'Cash';

  @override
  String get bizPaymentOther => 'Other';

  @override
  String get bizAdultPromotions => 'Has promotions for adults';

  @override
  String get bizDayMonday => 'Monday';

  @override
  String get bizDayTuesday => 'Tuesday';

  @override
  String get bizDayWednesday => 'Wednesday';

  @override
  String get bizDayThursday => 'Thursday';

  @override
  String get bizDayFriday => 'Friday';

  @override
  String get bizDaySaturday => 'Saturday';

  @override
  String get bizDaySunday => 'Sunday';

  @override
  String get bizScheduleTitle => 'Opening hours';

  @override
  String get bizClosed => 'Closed';

  @override
  String get bizMyPromos => 'My promotions';

  @override
  String get bizFeaturedHint => 'Turn on \"Featured\" so your promo appears first in search.';

  @override
  String get bizNoPromosYet => 'You don\'t have any promotions in this business yet.';

  @override
  String get bizPlanLimitTitle => 'You reached your plan\'s limit';

  @override
  String get bizBuyExtraSpaceDesc => 'Buy extra space and keep publishing without changing your plan.';

  @override
  String get bizBuyPromoSpace => 'Buy promotion space';

  @override
  String bizEditAvailableOn(Object date) {
    return 'Editing available on $date';
  }

  @override
  String get bizPromoNotEditableYet => 'This promotion can\'t be edited yet.';

  @override
  String bizEditableOn(Object date) {
    return 'Editable on $date';
  }

  @override
  String get bizLocked => 'Locked';

  @override
  String get bizFeatured => 'Featured';

  @override
  String get bizFlash => 'Flash';

  @override
  String get bizMyTeam => 'My team';

  @override
  String get bizInvite => 'Invite';

  @override
  String get bizRemoveFromTeamTitle => 'Remove from team';

  @override
  String bizRemoveFromTeamConfirm(Object name) {
    return 'Remove $name from the team?';
  }

  @override
  String get bizCancel => 'Cancel';

  @override
  String get bizRemove => 'Remove';

  @override
  String bizRemoveTeamError(Object error) {
    return 'Error removing from team: $error';
  }

  @override
  String get bizNoStaffYet => 'No staff yet.\nTap \"Invite\" to generate a code.';

  @override
  String get bizRemoveFromTeamTooltip => 'Remove from team';

  @override
  String bizGenerateCodeError(Object error) {
    return 'Error generating code: $error';
  }

  @override
  String get bizInviteStaff => 'Invite staff member';

  @override
  String get bizCodeAvailable48h => 'The code will be available for 48 hours.';

  @override
  String get bizRoleLabel => 'ROLE';

  @override
  String get bizRoleCashier => 'Cashier / Server';

  @override
  String get bizRoleCashierDesc => 'Can only scan the loyalty QR';

  @override
  String get bizRoleManager => 'Manager';

  @override
  String get bizRoleManagerDesc => 'Statistics, promos and loyalty QR';

  @override
  String get bizRoleCustom => 'Custom';

  @override
  String get bizRoleCustomDesc => 'Choose permissions manually';

  @override
  String get bizPermissionsLabel => 'PERMISSIONS';

  @override
  String get bizPermScanQr => 'Scan loyalty QR';

  @override
  String get bizPermViewStats => 'View statistics';

  @override
  String get bizPermManagePromos => 'Manage promotions';

  @override
  String get bizPermManagePayments => 'Manage payments';

  @override
  String get bizGenerating => 'Generating…';

  @override
  String get bizGenerateCode => 'Generate code';

  @override
  String get bizCodeGenerated => 'Code generated';

  @override
  String bizCodeRole(Object role) {
    return 'Role: $role';
  }

  @override
  String get bizCodeValid48h => 'Valid for 48 hours.\nShare it with the staff member to enter in the app.';

  @override
  String get bizCodeCopied => 'Code copied';

  @override
  String get bizCopyCode => 'Copy code';

  @override
  String get bizDone => 'Done';

  @override
  String get bizPushNotifications => 'Push notifications';

  @override
  String get bizNoNotifications => 'No notifications in this period.\nThey are generated automatically when you create a flash promo.';

  @override
  String get bizKpiSent => 'Sends';

  @override
  String get bizKpiReached => 'Reached';

  @override
  String get bizKpiOpenRate => 'Open rate';

  @override
  String get bizRecentHistory => 'RECENT HISTORY';

  @override
  String bizNotifSentLine(Object date, Object count) {
    return '$date · $count sent';
  }

  @override
  String bizOpenRateShort(Object pct) {
    return '$pct% opens';
  }

  @override
  String get bizBoostBusiness => 'Boost your business';

  @override
  String bizPlanIncludes(Object plan, Object establishments, Object promotions) {
    return 'Your \"$plan\" plan includes up to $establishments businesses and $promotions regular promotions.';
  }

  @override
  String get bizEmptyTagline => 'Publish promotions and reach thousands of customers in your city.';

  @override
  String get bizRegisterMyBusiness => 'Register my business';

  @override
  String get bizAdvertising => 'Advertising';

  @override
  String get bizNewCampaign => 'New campaign';

  @override
  String get bizAvailableCredit => 'Available credit';

  @override
  String bizReachableBanner(Object count) {
    return '≈ $count people reachable (banner)';
  }

  @override
  String get bizTopUp => 'Top up';

  @override
  String get bizWalletTitle => 'Promofy wallet';

  @override
  String get bizWalletUse => 'Use';

  @override
  String get bizWalletDialogTitle => 'Use wallet credits';

  @override
  String get bizWalletDialogDesc => 'Move credit from your wallet to this venue\'s advertising balance. That balance is what gets spent on your ads.';

  @override
  String get bizWalletAll => 'All';

  @override
  String get bizWalletApply => 'Apply';

  @override
  String get bizWalletCancel => 'Cancel';

  @override
  String get bizWalletInvalid => 'Invalid amount.';

  @override
  String get bizWalletInsufficient => 'You don\'t have enough wallet balance.';

  @override
  String get bizWalletError => 'Couldn\'t apply the credit.';

  @override
  String get bizWalletApplied => 'Done! Credit applied to the venue\'s balance.';

  @override
  String get bizNoActiveCampaigns => 'No active campaigns';

  @override
  String get bizOngoingCampaigns => 'Ongoing campaigns';

  @override
  String bizSpent(Object amount) {
    return 'Spent: $amount';
  }

  @override
  String bizBudget(Object amount) {
    return 'Budget: $amount';
  }

  @override
  String get bizPause => 'Pause';

  @override
  String get bizResume => 'Resume';

  @override
  String get bizTransactionHistory => 'Transaction history';

  @override
  String get bizRetry => 'Retry';

  @override
  String get bizGeoBoth => 'Physical + search';

  @override
  String get bizGeoPhysical => 'Physical location only';

  @override
  String get bizGeoSearchArea => 'Search area only';

  @override
  String get bizErrorNameRequired => 'The name is required';

  @override
  String get bizErrorBudgetInvalid => 'Enter a valid budget';

  @override
  String bizErrorMinBudget(Object amount) {
    return 'Minimum budget for this format: $amount';
  }

  @override
  String bizErrorInsufficientBalance(Object amount) {
    return 'Insufficient balance. Available: $amount';
  }

  @override
  String get bizErrorSelectPromo => 'Select the promotion you want to advertise';

  @override
  String get bizCampaignName => 'Campaign name';

  @override
  String get bizWhatToAdvertise => 'What will you advertise?';

  @override
  String get bizYourBusiness => 'Your business';

  @override
  String get bizOnePromotion => 'A promotion';

  @override
  String get bizWhereToShow => 'Where do you want to show it?';

  @override
  String get bizPlacementSplash => 'Splash when opening the app';

  @override
  String get bizPlacementFeed => 'In the promos feed';

  @override
  String get bizPlacementBanner => 'Banner on the home screen';

  @override
  String get bizSpecialFormats => 'Special formats';

  @override
  String get bizFormatPush => 'Push notif.';

  @override
  String get bizFormatFlash => 'Flash Promo';

  @override
  String get bizBudgetMxn => 'Budget (MXN)';

  @override
  String bizMinimum(Object amount) {
    return 'Minimum $amount';
  }

  @override
  String bizEstimatedReach(Object count) {
    return 'Estimated reach: $count people';
  }

  @override
  String get bizRadius => 'Radius:';

  @override
  String get bizGeoSegmentation => 'Geographic targeting';

  @override
  String get bizAge => 'Age:';

  @override
  String bizAgeRange(Object min, Object max) {
    return '$min – $max years';
  }

  @override
  String bizYearsOld(Object age) {
    return '$age years';
  }

  @override
  String get bizGender => 'Gender';

  @override
  String get bizGenderAll => 'All';

  @override
  String get bizGenderMale => 'Men';

  @override
  String get bizGenderFemale => 'Women';

  @override
  String bizAudienceWithFilters(Object count) {
    return 'Audience with these filters: $count people';
  }

  @override
  String get bizCalculatingAudience => 'Calculating audience...';

  @override
  String get bizPromoToAdvertise => 'Promotion to advertise';

  @override
  String get bizCreatePromoFirst => 'Create at least one active promotion before launching a campaign.';

  @override
  String get bizLaunchCampaign => 'Launch campaign';

  @override
  String get bizRefresh => 'Refresh';

  @override
  String get bizNoAssignedEstablishments => 'No assigned establishments';

  @override
  String get bizAskOwnerToInvite => 'Ask the business owner to invite you with a code.';

  @override
  String get bizPermManagePromosShort => 'Manage promos';

  @override
  String get bizScanStamps => 'Scan stamps';

  @override
  String get bizPromoTypeFlash => 'Flash';

  @override
  String get bizPromoTypeDaily => 'Daily';

  @override
  String get bizPromoTypeWeekly => 'Weekly';

  @override
  String get bizPromoTypePermanent => 'Permanent';

  @override
  String get bizActive => 'Active';

  @override
  String get bizInactive => 'Inactive';

  @override
  String get bizMinAmount50 => 'Enter a minimum amount of \$50 MXN';

  @override
  String get bizCannotOpenMercadoPago => 'Could not open MercadoPago';

  @override
  String get bizRedirectedToMercadoPago => 'Redirected to MercadoPago. Your balance will update within minutes after payment.';

  @override
  String get bizTopUpAdCredit => 'Top up advertising credit';

  @override
  String get bizTopUpDesc => 'Each impression deducts credit according to the campaign format. Payment is processed by MercadoPago.';

  @override
  String get bizAmountToTopUp => 'AMOUNT TO TOP UP';

  @override
  String get bizOtherAmount => 'Other amount';

  @override
  String get bizMin50Mxn => 'Minimum \$50 MXN';

  @override
  String bizTotalToPay(Object amount) {
    return 'Total to pay: $amount MXN';
  }

  @override
  String get bizPreparingPayment => 'Preparing payment…';

  @override
  String get bizPayWithMercadoPago => 'Pay with MercadoPago';

  @override
  String get bizWillRedirectMercadoPago => 'You will be redirected to the MercadoPago site.';

  @override
  String get regBizCreateTitle => 'Register business';

  @override
  String get regBizEditTitle => 'Edit business';

  @override
  String get regBizBack => 'Back';

  @override
  String get regBizNext => 'Next';

  @override
  String get regBizSaveChanges => 'Save changes';

  @override
  String regBizStepOf(Object step, Object total) {
    return 'Step $step of $total';
  }

  @override
  String get regBizStepBasic => 'Basic details';

  @override
  String get regBizStepType => 'Type and category';

  @override
  String get regBizStepSchedule => 'Hours and extras';

  @override
  String get regBizUpdatedOk => 'Business updated successfully.';

  @override
  String get regBizCreatedOk => 'Business registered! You now appear on Promofy.';

  @override
  String get regBizSelectAddressHint => 'Select an address from the search to get the location.';

  @override
  String get regBizSelectType => 'Select the establishment type.';

  @override
  String get regBizSelectCategory => 'Select at least one category.';

  @override
  String get regBizSelectCharacteristic => 'Select at least one feature.';

  @override
  String get regBizSelectPayment => 'Select at least one payment method.';

  @override
  String get regBizSelectDay => 'Add at least one opening day.';

  @override
  String get regBizSectionMain => 'Main information';

  @override
  String get regBizNameLabel => 'Business name *';

  @override
  String get regBizNameHint => 'E.g. Tacos El Gordo';

  @override
  String get regBizNameRequired => 'The name is required';

  @override
  String get regBizDescLabel => 'Description';

  @override
  String get regBizDescHint => 'Briefly describe your business…';

  @override
  String get regBizSectionLocation => 'Location';

  @override
  String get regBizAddressLabel => 'Address';

  @override
  String get regBizAddressLabelRequired => 'Address *';

  @override
  String get regBizAddressHint => 'Tap to search the address…';

  @override
  String get regBizAddressHelper => 'Select the address from the suggestions to get coordinates.';

  @override
  String get regBizSectionContact => 'Contact';

  @override
  String get regBizPhoneLabel => 'Phone / WhatsApp';

  @override
  String get regBizPhoneHint => 'E.g. 4491234567';

  @override
  String get regBizSectionSocial => 'Social media';

  @override
  String get regBizWebsiteLabel => 'Website';

  @override
  String get regBizTypeSection => 'Establishment type *';

  @override
  String get regBizTypeLocal => 'Storefront';

  @override
  String get regBizTypeLocalSub => 'Fixed address';

  @override
  String get regBizTypeMobile => 'Urban / Mobile';

  @override
  String get regBizTypeMobileSub => 'Variable location';

  @override
  String get regBizCategorySection => 'Category *';

  @override
  String get regBizCategoryHelper => 'You can select one or more. The subcategory is optional.';

  @override
  String get regBizSubcategoryLabel => '↳ Subcategory (optional)';

  @override
  String get regBizSpecialtyLabel => '↳ Specialty (optional)';

  @override
  String get regBizExtraSection => 'Additional information';

  @override
  String get regBizAdultPromos => 'Does it offer promotions for adults?';

  @override
  String get regBizScheduleSection => 'Opening hours *';

  @override
  String get regBizScheduleHelper => 'Enable the days you are open and adjust the hours.';

  @override
  String get regBizCharSection => 'Features *';

  @override
  String get regBizCharHelper => 'Select the ones that apply to your business.';

  @override
  String get regBizPaymentSection => 'Payment methods *';

  @override
  String get regBizPaymentCard => 'Credit/debit card';

  @override
  String get regBizPaymentCash => 'Cash';

  @override
  String get regBizPaymentOther => 'Other';

  @override
  String get regBizClosed => 'Closed';

  @override
  String get regBizDayMonday => 'Monday';

  @override
  String get regBizDayTuesday => 'Tuesday';

  @override
  String get regBizDayWednesday => 'Wednesday';

  @override
  String get regBizDayThursday => 'Thursday';

  @override
  String get regBizDayFriday => 'Friday';

  @override
  String get regBizDaySaturday => 'Saturday';

  @override
  String get regBizDaySunday => 'Sunday';

  @override
  String get regBizSearchAddressTitle => 'Search address';

  @override
  String get regBizSearchAddressHint => 'Type your business address…';

  @override
  String get regBizNoResults => 'No results. Try a different search.';

  @override
  String get regBizSearchError => 'Search error. Please try again.';

  @override
  String get regBizLocationError => 'Could not get the location.';

  @override
  String get promoFormEditTitle => 'Edit promotion';

  @override
  String get promoFormNewTitle => 'New promotion';

  @override
  String get promoFormDelete => 'Delete';

  @override
  String get promoFormCancel => 'Cancel';

  @override
  String get promoFormClear => 'Clear';

  @override
  String get promoFormSelectThis => 'Select this one';

  @override
  String get promoFormCategorySheetTitle => 'Promotion category';

  @override
  String get promoFormCategoryLevel1 => 'Category';

  @override
  String get promoFormSubcategory => 'Subcategory';

  @override
  String get promoFormSpecialty => 'Specialty';

  @override
  String get promoFormOptionalTag => 'optional';

  @override
  String get promoFormStartDate => 'Start date';

  @override
  String get promoFormEndDate => 'End date';

  @override
  String get promoFormStartTime => 'Start time';

  @override
  String get promoFormEndTime => 'End time';

  @override
  String get promoFormEndTimeSameDay => 'End time (same day)';

  @override
  String get promoFormErrorNameRequired => 'The name is required.';

  @override
  String get promoFormErrorSelectDay => 'Select at least one day.';

  @override
  String get promoFormErrorStartDateTime => 'Set the start date and time.';

  @override
  String get promoFormErrorEndTime => 'Set the end time.';

  @override
  String get promoFormErrorEndAfterStart => 'The end time must be after the start.';

  @override
  String get promoFormErrorSameDay => 'A flash promo must start and end on the same day.';

  @override
  String get promoFormConfirmTitle => 'Is everything correct?';

  @override
  String promoFormConfirmName(Object name) {
    return '\"$name\"';
  }

  @override
  String get promoFormConfirmIntro => 'Once created, ';

  @override
  String get promoFormConfirmLockWarning => 'you won\'t be able to edit this promotion for 15 days.';

  @override
  String get promoFormConfirmReview => '\n\nCarefully review the name, description, schedule and active days before continuing.';

  @override
  String get promoFormReviewMore => 'Review more';

  @override
  String get promoFormConfirmCreate => 'Yes, create promotion';

  @override
  String promoFormSaveError(Object error) {
    return 'Error saving: $error';
  }

  @override
  String get promoFormDeleteTitle => 'Delete promotion';

  @override
  String get promoFormDeleteConfirm => 'Delete this promotion? This action cannot be undone.';

  @override
  String promoFormDeleteError(Object error) {
    return 'Error deleting: $error';
  }

  @override
  String get promoFormTypeLabel => 'Promotion type';

  @override
  String get promoFormTypeNormal => 'Normal';

  @override
  String get promoFormTypeFlash => 'Flash ⚡';

  @override
  String get promoFormTypeBirthday => 'Birthday 🎂';

  @override
  String get promoFormTypeNormalDesc => 'Repeats every week on the chosen days and schedule.';

  @override
  String get promoFormTypeFlashDesc => 'One-off event, valid for a single day. Maximum 1 flash per month.';

  @override
  String get promoFormTypeBirthdayDesc => 'Available every day of the year for customers celebrating their birthday.';

  @override
  String get promoFormNameLabel => 'Name *';

  @override
  String get promoFormNameHint => 'E.g.: 2-for-1 on cocktails';

  @override
  String get promoFormDescriptionLabel => 'Description';

  @override
  String get promoFormDescriptionHint => 'Tell your customers the details';

  @override
  String get promoFormBirthdayGiftLabel => 'Birthday gift *';

  @override
  String get promoFormBirthdayGiftHint => 'E.g.: Free dessert, complimentary drink…';

  @override
  String get promoFormBirthdayTermsLabel => 'Conditions (optional)';

  @override
  String get promoFormBirthdayTermsHint => 'E.g.: Show your ID on your birthday';

  @override
  String get promoFormPhotoLabel => 'Photo (optional)';

  @override
  String get promoFormPhotoTapToAdd => 'Tap to add a photo';

  @override
  String get promoFormCategoryLabel => 'Category (optional)';

  @override
  String get promoFormCategorySelected => 'Selected category';

  @override
  String get promoFormCategoryLoading => 'Loading categories...';

  @override
  String get promoFormCategoryNone => 'No category';

  @override
  String get promoFormAdultTitle => 'Adult content';

  @override
  String get promoFormAdultSubtitle => 'Only visible to users 18+';

  @override
  String get promoFormSaveChanges => 'Save changes';

  @override
  String get promoFormCreate => 'Create promotion';

  @override
  String get promoFormActiveDaysLabel => 'Active days *';

  @override
  String get promoFormScheduleLabel => 'Schedule';

  @override
  String get promoFormStartLabel => 'Start';

  @override
  String get promoFormEndLabel => 'End';

  @override
  String get promoFormEventStartLabel => 'Event start *';

  @override
  String get promoFormEventEndLabel => 'Event end *';

  @override
  String get promoFormEndTimeSameDayLabel => 'End time * (same day)';

  @override
  String get promoFormPickDateTime => 'Select date and time';

  @override
  String get promoFormPickEndTime => 'Select end time';

  @override
  String get promoFormFlashInfo => 'A flash promo must start and end on the same day. Only one per month per business is allowed.';

  @override
  String get adminPlacesTitle => 'Manage Places';

  @override
  String get adminPlacesRefresh => 'Refresh';

  @override
  String get adminPlacesTabEstablishments => 'Establishments';

  @override
  String get adminPlacesTabPromos => 'Promotions';

  @override
  String get adminPlacesAddPlace => 'Add place';

  @override
  String get adminPlacesSearchHint => 'Search…';

  @override
  String adminPlacesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places',
      one: '1 place',
    );
    return '$_temp0';
  }

  @override
  String get adminPlacesEmpty => 'No places yet. Tap + to add one.';

  @override
  String get adminPlacesNoResults => 'No results.';

  @override
  String get adminPlacesEditInfo => 'Edit info';

  @override
  String get adminPlacesManagePhotos => 'Manage photos';

  @override
  String get adminPlacesDelete => 'Delete';

  @override
  String get adminPlacesManagePromos => 'Manage promotions';

  @override
  String adminPlacesPhotosTitle(Object name) {
    return 'Photos — $name';
  }

  @override
  String get adminPlacesDeleteTitle => 'Delete place';

  @override
  String adminPlacesDeleteConfirm(Object name) {
    return 'Delete \"$name\"?\nIts promotions will also be deleted.';
  }

  @override
  String get adminPlacesCancel => 'Cancel';

  @override
  String adminPlacesError(Object error) {
    return 'Error: $error';
  }

  @override
  String get adminPlacesNoPlacesYet => 'First create a place in the Establishments tab.';

  @override
  String get adminPlacesSelectPlace => 'Select a place';

  @override
  String get adminPlacesNewPromo => 'New promotion';

  @override
  String get adminPlacesChoosePlace => 'Choose a place to see its promotions.';

  @override
  String get adminPlacesNoPromos => 'No promotions. Tap \"New promotion\".';

  @override
  String get adminPlacesPromoActive => 'Active';

  @override
  String get adminPlacesPromoInactive => 'Inactive';

  @override
  String get adminPlacesEdit => 'Edit';

  @override
  String get adminMetricsTitle => 'Admin Panel';

  @override
  String get adminMetricsManageRestaurants => 'Manage restaurants';

  @override
  String get adminMetricsRefresh => 'Refresh metrics';

  @override
  String get adminMetricsRetry => 'Retry';

  @override
  String get adminMetricsAdminPlaces => 'Manage Places';

  @override
  String get adminMetricsAdminPlacesSubtitle => 'Manage admin establishments and promotions';

  @override
  String get adminMetricsSectionUsers => 'Users';

  @override
  String get adminMetricsNewUsers => 'New users';

  @override
  String get adminMetricsActiveUsers => 'Active users';

  @override
  String get adminMetricsPeriodToday => 'Today';

  @override
  String get adminMetricsPeriod7d => '7 days';

  @override
  String get adminMetricsPeriod15d => '15 days';

  @override
  String get adminMetricsPeriod30d => '30 days';

  @override
  String get adminMetricsPeriodTotal => 'Total';

  @override
  String get adminMetricsSectionPlatform => 'Platform';

  @override
  String get adminMetricsEstablishments => 'Establishments';

  @override
  String adminMetricsNewThisMonth(Object count) {
    return '$count this month';
  }

  @override
  String get adminMetricsActivePromos => 'Active promos';

  @override
  String adminMetricsTotalCount(Object count) {
    return '$count total';
  }

  @override
  String get adminMetricsSectionLoyaltyQr => 'Loyalty & QR';

  @override
  String get adminMetricsTotalScans => 'Total scans';

  @override
  String adminMetricsLast30dValue(Object count) {
    return '$count last 30d';
  }

  @override
  String get adminMetricsAvgTicket => 'Average ticket';

  @override
  String get adminMetricsWaiterUploadedAmount => 'Amount uploaded by waiters';

  @override
  String get adminMetricsSectionCampaigns => 'Ad Campaigns';

  @override
  String get adminMetricsActiveCampaigns => 'Active campaigns';

  @override
  String get adminMetricsCreditsSold => 'Credits sold';

  @override
  String get adminMetricsLast30days => 'last 30 days';

  @override
  String get adminMetricsCampaignSpend => 'Campaign spend';

  @override
  String get adminMetricsSectionSubscriptions => 'Subscriptions';

  @override
  String get adminMetricsActiveSubscriptions => 'Active subscriptions';

  @override
  String get adminMetricsMonthlyIncome => 'monthly income';

  @override
  String get adminMetricsSectionPerformance => 'Performance';

  @override
  String get adminMetricsRegisteredUsers => 'registered users';

  @override
  String get adminMetricsRoleUsers => 'Users';

  @override
  String get adminMetricsRoleStaff => 'Staff';

  @override
  String get adminMetricsRoleBusiness => 'Businesses';

  @override
  String get adminMetricsRoleAdmin => 'Admin';

  @override
  String get adminMetricsPlatformRevenue30d => 'Platform revenue (30 days)';

  @override
  String get adminMetricsRevenueSubscriptions => 'Subscriptions\n(MRR)';

  @override
  String get adminMetricsRevenueAdCredits => 'Ad credits\n(30d)';

  @override
  String get adminMetricsRevenueRoas => 'ROAS\n(revenue/ad spend)';

  @override
  String get adminMetricsNotAvailable => 'N/A';

  @override
  String get adminEstTitle => 'Admin Restaurants';

  @override
  String get adminEstRefresh => 'Refresh';

  @override
  String get adminEstAdd => 'Add restaurant';

  @override
  String get adminEstSearchHint => 'Search by name or address…';

  @override
  String get adminEstLoading => 'Loading…';

  @override
  String adminEstCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count establishments',
      one: '1 establishment',
    );
    return '$_temp0';
  }

  @override
  String get adminEstRetry => 'Retry';

  @override
  String get adminEstEmpty => 'No restaurants managed by Admin yet.';

  @override
  String adminEstNoResults(Object query) {
    return 'No results for \"$query\".';
  }

  @override
  String get adminEstAddFirst => 'Add first one';

  @override
  String get adminEstDeleteTitle => 'Delete restaurant';

  @override
  String adminEstDeleteConfirm(Object name) {
    return 'Delete \"$name\"?\nThis will also delete its promotions and associated data.';
  }

  @override
  String get adminEstCancel => 'Cancel';

  @override
  String get adminEstDelete => 'Delete';

  @override
  String adminEstDeleted(Object name) {
    return '\"$name\" deleted.';
  }

  @override
  String adminEstDeleteError(Object error) {
    return 'Error deleting: $error';
  }

  @override
  String get adminEstEdit => 'Edit';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsRetry => 'Retry';

  @override
  String get statsBusinessViews => 'Business views';

  @override
  String get statsPromoViews => 'Promo views';

  @override
  String get statsNewFavs => 'New favs';

  @override
  String get statsContacts => 'Contacts';

  @override
  String get statsQrVisits => 'QR visits';

  @override
  String get statsTotalFavs => 'Total favs';

  @override
  String get statsAvgTicket => 'Avg. ticket';

  @override
  String get statsRevenue => 'Revenue generated';

  @override
  String get statsPromoBreakdown => 'BREAKDOWN BY PROMO';

  @override
  String get statsColPromo => 'Promo';

  @override
  String get statsColViews => 'Views';

  @override
  String get statsColViewsTooltip => 'Times the detail was opened';

  @override
  String get statsColNewFavs => 'Favs +';

  @override
  String get statsColNewFavsTooltip => 'New favorites in the period';

  @override
  String get statsColTotalFavs => 'Favs Σ';

  @override
  String get statsColTotalFavsTooltip => 'Total accumulated favorites';

  @override
  String get statsContactChannels => 'CONTACT CHANNELS';

  @override
  String get statsChannelPhone => 'Call';

  @override
  String get statsChannelWebsite => 'Website';

  @override
  String get statsChannelMaps => 'Map';

  @override
  String statsAudienceHeader(Object total) {
    return 'AUDIENCE ($total favoriters)';
  }

  @override
  String get statsGender => 'Gender';

  @override
  String get statsAge => 'Age';

  @override
  String get statsByPromo => 'By promotion';

  @override
  String get statsGenderMale => 'Men';

  @override
  String get statsGenderFemale => 'Women';

  @override
  String get statsGenderUnknown => 'N/A';

  @override
  String get photosSectionTitle => 'Logo and photos';

  @override
  String get photosLogoTitle => 'Business logo';

  @override
  String get photosLogoHint => 'Square image, minimum 400×400 px.';

  @override
  String get photosChangeLogo => 'Change logo';

  @override
  String get photosUploadLogo => 'Upload logo';

  @override
  String get photosCategoryEstablishment => 'Establishment photos';

  @override
  String get photosCategoryChildrenArea => 'Children\'s area';

  @override
  String get photosCategoryMenu => 'Menu';

  @override
  String get photosEmpty => 'No photos';

  @override
  String get photosDeleteTitle => 'Delete photo';

  @override
  String get photosDeleteConfirm => 'Are you sure you want to delete this photo?';

  @override
  String get photosCancel => 'Cancel';

  @override
  String get photosDelete => 'Delete';

  @override
  String get photosErrorUploadLogo => 'Could not upload the logo. Please try again.';

  @override
  String get photosErrorUploadPhoto => 'Could not upload the photo. Please try again.';

  @override
  String get photosErrorDeletePhoto => 'Could not delete the photo. Please try again.';

  @override
  String get adminPanelTitle => 'Superadmin Panel';

  @override
  String get adminReload => 'Reload';

  @override
  String get adminLoadError => 'Failed to load';

  @override
  String get adminRetry => 'Retry';

  @override
  String get adminSectionTitle => 'Administration';

  @override
  String get adminTilePlans => 'Membership plans';

  @override
  String adminTilePlansSubtitle(Object count) {
    return '$count plans configured';
  }

  @override
  String get adminTileOwners => 'Business owners';

  @override
  String adminTileOwnersSubtitle(Object count) {
    return '$count registered owners';
  }

  @override
  String get adminTileCategories => 'Categories';

  @override
  String adminTileCategoriesSubtitle(Object count) {
    return '$count categories · type tree';
  }

  @override
  String get adminTileCharacteristics => 'Features';

  @override
  String adminTileCharacteristicsSubtitle(Object count) {
    return '$count features';
  }

  @override
  String get adminTileNotifications => 'Push notifications';

  @override
  String adminTileNotificationsSubtitle(Object devices, Object sends) {
    return '$devices devices · $sends sends logged';
  }

  @override
  String get adminTileAllUsers => 'All users';

  @override
  String get adminTileAllUsersSubtitle => 'Manage accounts · activate / deactivate';

  @override
  String get adminTileAds => 'Advertising';

  @override
  String get adminTileAdsSubtitle => 'Prices by format · campaign management';

  @override
  String get adminTileCredits => 'Ad credits';

  @override
  String get adminTileCreditsSubtitle => 'Assign balance to establishment accounts';

  @override
  String get adminTileBulk => 'Bulk promo upload';

  @override
  String get adminTileBulkSubtitle => 'Create promotions for businesses · doesn\'t count against the plan';

  @override
  String get adminRoleFilterAll => 'All';

  @override
  String get adminRoleFilterUsers => 'Users';

  @override
  String get adminRoleFilterStaff => 'Staff';

  @override
  String get adminRoleFilterOwners => 'Owners';

  @override
  String get adminRoleFilterAdmin => 'Admin';

  @override
  String adminErrorWithMsg(Object msg) {
    return 'Error: $msg';
  }

  @override
  String get adminAllUsersTitle => 'All users';

  @override
  String get adminSearchNameEmail => 'Search by name or email…';

  @override
  String adminUserCount(Object count) {
    return '$count user(s)';
  }

  @override
  String get adminNoResults => 'No results';

  @override
  String get adminAccountDeactivated => 'Account deactivated';

  @override
  String get adminActivate => 'Activate';

  @override
  String get adminDeactivate => 'Deactivate';

  @override
  String get adminActivateAccount => 'Activate account';

  @override
  String get adminDeactivateAccount => 'Deactivate account';

  @override
  String adminActivateAccountConfirm(Object name) {
    return 'Reactivate $name\'s account? They will be able to sign in again.';
  }

  @override
  String adminDeactivateAccountConfirm(Object name) {
    return 'Deactivate $name\'s account? They won\'t be able to sign in and their content will be hidden.';
  }

  @override
  String get adminCancel => 'Cancel';

  @override
  String get adminPlansTitle => 'Membership plans';

  @override
  String get adminAddons => 'Add-ons';

  @override
  String get adminAddonsDesc => 'Per-unit/month prices charged above the plan limit.';

  @override
  String get adminAddonTableMissing => 'addon_pricing table not found.';

  @override
  String get adminAddonRunSql => 'Run the add-ons SQL in Supabase first.';

  @override
  String get adminOwnersTitle => 'Business owners';

  @override
  String adminResultCount(Object count) {
    return '$count result(s)';
  }

  @override
  String get adminCategoriesTitle => 'Categories';

  @override
  String get adminNewRootType => 'New root type';

  @override
  String get adminNoCategories => 'No categories';

  @override
  String get adminLevelType => 'Type';

  @override
  String get adminLevelSubtype => 'Subtype';

  @override
  String get adminLevelSubSubtype => 'Sub-subtype';

  @override
  String get adminAddSubcategory => 'Add subcategory';

  @override
  String get adminDeleteCategory => 'Delete category';

  @override
  String adminDeleteCategoryWithChildren(Object name, Object count) {
    return 'Delete \"$name\"? Its $count subcategory(ies) will also be deleted.';
  }

  @override
  String adminDeleteCategorySimple(Object name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get adminDelete => 'Delete';

  @override
  String get adminCharacteristicsTitle => 'Features';

  @override
  String get adminNewCharacteristic => 'New feature';

  @override
  String get adminNoCharacteristics => 'No features';

  @override
  String get adminDeleteCharacteristic => 'Delete feature';

  @override
  String adminDeleteCharacteristicConfirm(Object name) {
    return 'Delete \"$name\"? It will be removed from all establishments.';
  }

  @override
  String get adminFree => 'Free';

  @override
  String adminPricePerMonth(Object price) {
    return '\$$price MXN/month';
  }

  @override
  String adminBusinessCount(Object count) {
    return '$count business(es)';
  }

  @override
  String adminPromoCount(Object count) {
    return '$count promo(s)';
  }

  @override
  String get adminEditPlan => 'Edit plan';

  @override
  String get adminFreeNoCharge => 'Free / no charge';

  @override
  String get adminEditPrice => 'Edit price';

  @override
  String adminEditLabel(Object label) {
    return 'Edit: $label';
  }

  @override
  String get adminInvalidPriceMin => 'Enter a valid price (0 or higher).';

  @override
  String get adminMonthlyPricePerUnit => 'Monthly price per unit (MXN)';

  @override
  String get adminNoAdditionalCharge => '0 = no additional charge';

  @override
  String get adminAddonZeroHint => 'Enter 0 if the add-on is free or not yet active.';

  @override
  String get adminSavePrice => 'Save price';

  @override
  String adminEditPlanLabel(Object name) {
    return 'Edit plan: $name';
  }

  @override
  String get adminPriceMxnMonth => 'Price (MXN/month)';

  @override
  String get adminZeroForFree => '0 for a free plan';

  @override
  String get adminMaxEstablishments => 'Max. establishments';

  @override
  String get adminMaxActivePromos => 'Max. active promotions';

  @override
  String get adminSaveChanges => 'Save changes';

  @override
  String adminPlanPickerSubtitle(Object price, Object est, Object promos) {
    return '\$$price MXN/month · $est biz · $promos promos';
  }

  @override
  String get adminEdit => 'Edit';

  @override
  String get adminNameEmpty => 'The name cannot be empty.';

  @override
  String get adminNewCategory => 'New category';

  @override
  String get adminEditCategory => 'Edit category';

  @override
  String get adminNameRequired => 'Name *';

  @override
  String get adminEmojiIcon => 'Emoji / icon';

  @override
  String get adminBelongsToParent => 'Belongs to (parent)';

  @override
  String get adminNoParentRoot => '— No parent (Root type) —';

  @override
  String get adminCreateCategory => 'Create category';

  @override
  String get adminEditCharacteristic => 'Edit feature';

  @override
  String get adminCreateCharacteristic => 'Create feature';

  @override
  String get adminNotificationsTitle => 'Push notifications';

  @override
  String get adminTabSend => 'Send';

  @override
  String get adminTabScheduled => 'Scheduled';

  @override
  String get adminTabHistory => 'History';

  @override
  String get adminTabMetrics => 'Metrics';

  @override
  String get adminCompleteTitleBody => 'Complete title and message';

  @override
  String get adminCompleteTitleBodyBeforeSchedule => 'Complete title and message before scheduling';

  @override
  String adminSentResult(Object count) {
    return '✅ Sent to $count devices';
  }

  @override
  String adminSentResultWithFailed(Object count, Object failed) {
    return '✅ Sent to $count devices · $failed failed';
  }

  @override
  String adminSendErrorResult(Object msg) {
    return '❌ Error: $msg';
  }

  @override
  String get adminScheduledOk => '📅 Notification scheduled successfully';

  @override
  String adminTotalDevices(Object count) {
    return 'Total: $count devices';
  }

  @override
  String get adminTitleRequired => 'Title *';

  @override
  String get adminTitleHint => 'E.g. New feature available';

  @override
  String get adminMessageRequired => 'Message *';

  @override
  String get adminBodyHint => 'Write the body…';

  @override
  String get adminSegmentRecipients => 'Segment recipients';

  @override
  String get adminGender => 'Gender';

  @override
  String get adminAllGenders => 'All genders';

  @override
  String get adminAll => 'All';

  @override
  String get adminMen => 'Men';

  @override
  String get adminWomen => 'Women';

  @override
  String get adminPreferNotToSay => 'Prefer not to say';

  @override
  String get adminAgeRange => 'Age range';

  @override
  String get adminMin => 'Min';

  @override
  String get adminMax => 'Max';

  @override
  String get adminInactiveUsersSince => 'Users inactive for';

  @override
  String get adminNoFilter => 'No filter';

  @override
  String get adminDays7 => '7 days';

  @override
  String get adminDays15 => '15 days';

  @override
  String get adminDays30 => '30 days';

  @override
  String get adminDays60 => '60 days';

  @override
  String get adminDays90Plus => '90 days or more';

  @override
  String get adminPlatform => 'Platform';

  @override
  String get adminAllFem => 'All';

  @override
  String get adminCalculating => 'Calculating…';

  @override
  String adminRecipientsApprox(Object count) {
    return '~$count recipients';
  }

  @override
  String get adminEstimateRecipients => 'Estimate recipients';

  @override
  String get adminSchedule => 'Schedule';

  @override
  String get adminSending => 'Sending…';

  @override
  String get adminSendNow => 'Send now';

  @override
  String get adminNoScheduled => 'No scheduled notifications';

  @override
  String get adminNoScheduledHint => 'Use the Send → Schedule tab';

  @override
  String adminNextSend(Object date) {
    return 'Next: $date';
  }

  @override
  String adminRunCount(Object count) {
    return '$count run(s)';
  }

  @override
  String get adminNoSends => 'No sends logged.';

  @override
  String get adminTotalSent => 'Total sent';

  @override
  String get adminAvgDelivery => 'Avg. delivery';

  @override
  String get adminAvgOpen => 'Avg. open';

  @override
  String get adminDailySends30 => 'Daily sends — last 30 days';

  @override
  String get adminLegendSent => 'Sent';

  @override
  String get adminLegendOpens => 'Opens';

  @override
  String get adminNoSendData => 'No send data yet.';

  @override
  String get adminDevicesByPlatform => 'Devices by platform';

  @override
  String get adminLatestNotifications => 'Latest notifications';

  @override
  String get adminColNotification => 'Notification';

  @override
  String get adminColDelivery => 'Delivery';

  @override
  String get adminColOpen => 'Open';

  @override
  String get adminPickDateTime => 'Choose the send date and time';

  @override
  String get adminScheduleNotification => 'Schedule notification';

  @override
  String get adminSendDateTime => 'Send date and time *';

  @override
  String get adminSelect => 'Select…';

  @override
  String get adminRepetition => 'Repetition';

  @override
  String get adminOnceOnly => 'Once only';

  @override
  String get adminDaily => 'Daily';

  @override
  String get adminWeekly => 'Weekly';

  @override
  String get adminMonthly => 'Monthly';

  @override
  String get adminDelivered => 'delivered';

  @override
  String get adminFailed => 'failed';

  @override
  String get adminOpenStat => 'open';

  @override
  String get adminDeliveryStat => 'delivery';

  @override
  String get adminAdsPricesTitle => 'Advertising · Prices';

  @override
  String get adminNoPriceData => 'No price data';

  @override
  String get adminRunAdsSql => 'Run the advertising SQL in Supabase first.';

  @override
  String get adminPricesByFormat => 'Prices by format';

  @override
  String adminUsersCount(Object count) {
    return '$count users';
  }

  @override
  String get adminBillingUnitInfo => 'The billing unit (impressions per price) is calculated automatically based on active users: it grows with the platform.';

  @override
  String get adminMinCampaign => 'Min. campaign';

  @override
  String get adminInvalidPrice => 'Invalid price';

  @override
  String get adminInvalidMinBudget => 'Invalid minimum budget';

  @override
  String get adminPricePerThousand => 'Price per 1,000 impressions (MXN)';

  @override
  String get adminPricePerSend => 'Price per send (MXN)';

  @override
  String get adminFixedRate => 'Fixed rate (MXN)';

  @override
  String get adminMinCampaignBudget => 'Minimum campaign budget (MXN)';

  @override
  String get adminSave => 'Save';

  @override
  String get adminCreditsTitle => 'Ad credits';

  @override
  String get adminSearchEstOwner => 'Search establishment or owner…';

  @override
  String get adminBalance => 'balance';

  @override
  String get adminEnterValidAmount => 'Enter a valid amount';

  @override
  String get adminEnterDescription => 'Write a description';

  @override
  String adminCreditAdded(Object balance) {
    return 'Credit added successfully. New balance: $balance';
  }

  @override
  String adminCurrentBalance(Object balance) {
    return 'Current balance: $balance';
  }

  @override
  String get adminAmountToAdd => 'Amount to add (MXN)';

  @override
  String get adminDescriptionReason => 'Description / reason';

  @override
  String get adminSaving => 'Saving…';

  @override
  String get adminAddCredit => 'Add credit';

  @override
  String get adminBulkTitle => 'Superadmin bulk upload';

  @override
  String get adminTabEstablishments => 'Establishments';

  @override
  String get adminTabPromotions => 'Promotions';

  @override
  String get adminCsvEmpty => 'The CSV file is empty.';

  @override
  String get adminSelectOwner => 'Select an owner before continuing.';

  @override
  String get adminUploadCsvRow => 'Upload a CSV with at least one data row.';

  @override
  String adminRowEmptyName(Object row) {
    return 'Row $row: empty name';
  }

  @override
  String adminRowInvalidDays(Object row) {
    return 'Row $row: invalid days (use 1-7)';
  }

  @override
  String adminRowError(Object row, Object msg) {
    return 'Row $row: $msg';
  }

  @override
  String adminEstCreated(Object count) {
    return '$count establishment(s) created';
  }

  @override
  String adminPromosCreated(Object count) {
    return '$count promotion(s) created · they don\'t count against the plan';
  }

  @override
  String adminBulkEstBanner(Object count) {
    return 'Create establishments for any owner.\nThis session: $count created.';
  }

  @override
  String adminBulkPromoBanner(Object count) {
    return 'Create promotions for any business. They don\'t count against the plan limit.\nThis session: $count created.';
  }

  @override
  String get adminTemplateEstSubject => 'Promofy establishments template';

  @override
  String get adminTemplatePromoSubject => 'Promofy promotions template';

  @override
  String get adminDownloadCsvTemplate => 'Download CSV template';

  @override
  String get adminOwnerRequired => 'Owner *';

  @override
  String get adminSelectOwnerHint => 'Select an owner…';

  @override
  String get adminSelectCsvFile => 'Select CSV file';

  @override
  String adminPreviewRows(Object count) {
    return 'Preview ($count row(s)):';
  }

  @override
  String get adminCreatingEsts => 'Creating establishments…';

  @override
  String adminCreateEstsBtn(Object count) {
    return 'Create $count establishment(s)';
  }

  @override
  String get adminSelectEst => 'Select an establishment.';

  @override
  String get adminEstRequired => 'Establishment *';

  @override
  String get adminSelectBusinessHint => 'Select a business…';

  @override
  String get adminCreatingPromos => 'Creating promotions…';

  @override
  String adminCreatePromosBtn(Object count) {
    return 'Create $count promotion(s)';
  }

  @override
  String get logrosTitle => 'My Achievements';

  @override
  String get logrosLoadError => 'Couldn\'t load your achievements.';

  @override
  String get logrosRetry => 'Retry';

  @override
  String get logrosSectionVisits => 'Visit badges';

  @override
  String get logrosSectionStreaks => 'Weekly streaks';

  @override
  String logrosNextLevel(Object label) {
    return 'Next level: $label';
  }

  @override
  String logrosAnnualVisits(Object count) {
    return '$count annual visits';
  }

  @override
  String logrosConsecutiveWeeks(Object count) {
    return '$count consecutive weeks';
  }

  @override
  String logrosVisitsToGo(Object count) {
    return '$count more visits to reach it';
  }

  @override
  String get logrosStreakDescEnRacha => 'You visited businesses 3 weeks in a row';

  @override
  String get logrosStreakDescImparable => '8 weeks non-stop — you are unstoppable';

  @override
  String get logrosStreakDescLeyenda => '26 weeks (half a year) of a perfect streak';

  @override
  String get filterSheetTitle => 'Filters';

  @override
  String get filterSheetClearAll => 'Clear all';

  @override
  String get filterSheetSectionPlaceFeatures => 'Place features';

  @override
  String get filterSheetSectionCategory => 'Category';

  @override
  String get filterSheetSectionFoodType => 'Food type';

  @override
  String get filterSheetSectionDay => 'Day';

  @override
  String get filterSheetSectionPaymentMethod => 'Payment method';

  @override
  String get filterSheetApply => 'Apply filters';

  @override
  String filterSheetApplyWithCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'filters',
      one: 'filter',
    );
    return 'Apply ($count $_temp0)';
  }

  @override
  String get filterChipsActiveNow => 'Active now';

  @override
  String get filterChipsFlash => '⚡ Flash';

  @override
  String get filterChipsFavorites => '⭐ My favorites';

  @override
  String get filterChipsBirthday => '🎂 Birthday';

  @override
  String get filterChipsAdvancedMore => 'More filters';

  @override
  String filterChipsAdvancedCount(Object count) {
    return 'Filters ($count)';
  }

  @override
  String get adSplashAdLabel => 'Advertisement';

  @override
  String adSplashPromoSpecial(Object name) {
    return 'Special offer from $name';
  }

  @override
  String get adSplashDiscoverMsg => 'Tap to discover their exclusive promotions';

  @override
  String get adSplashViewPromos => 'View promotions';

  @override
  String get sponsoredCardBadge => 'Sponsored';

  @override
  String get sponsoredCardSeePromotions => 'See their promotions';

  @override
  String get sponsoredCardAd => 'Ad';

  @override
  String get adBannerSeePromotions => 'See their promotions';

  @override
  String get adBannerAdLabel => 'Ad';

  @override
  String get paymentResultGoHome => 'Go to home';

  @override
  String get paymentResultTryAgain => 'Try again';

  @override
  String get paymentResultSuccessTitle => 'Payment successful!';

  @override
  String get paymentResultSuccessSubtitle => 'Your advertising credit balance will be\nreflected in your dashboard in a few moments.';

  @override
  String get paymentResultFailureTitle => 'Payment not completed';

  @override
  String get paymentResultFailureSubtitle => 'No charge was made. You can\ntry again whenever you want.';

  @override
  String get paymentResultPendingTitle => 'Payment in progress';

  @override
  String get paymentResultPendingSubtitle => 'Your payment is being processed.\nWe will notify you once it is confirmed.';

  @override
  String get paymentResultSubscriptionTitle => 'Subscription activated!';

  @override
  String get paymentResultSubscriptionSubtitle => 'Your Promofy plan is now active.\nEnjoy all the features for your business.';

  @override
  String get locationPermTitle => 'Deals are waiting\nright near you!';

  @override
  String get locationPermSubtitle => 'Share your location to instantly see\nthe best deals sorted\nby distance.';

  @override
  String get locationPermAllowButton => 'Continue';

  @override
  String get locationPermSkipButton => 'Not now';

  @override
  String get splashScrTagline => 'Discover deals near you';

  @override
  String get settingsMyFavs => 'My favs';

  @override
  String get tourSkip => 'Skip';

  @override
  String get tourNext => 'Next';

  @override
  String get tourStart => 'Get started';

  @override
  String get tourReplay => 'View tutorial';

  @override
  String get tour1Title => 'Welcome to Promofy!';

  @override
  String get tour1Desc => 'Discover the best deals from restaurants and entertainment near you.';

  @override
  String get tour2Title => 'Explore near you';

  @override
  String get tour2Desc => 'In Home and Places you\'ll find deals and businesses sorted by distance. Use filters to find exactly what you\'re craving.';

  @override
  String get tour3Title => 'Flash deals';

  @override
  String get tour3Desc => 'Limited-time offers. Grab them before they\'re gone!';

  @override
  String get tour4Title => 'Loyalty stamps';

  @override
  String get tour4Desc => 'Check which businesses have a loyalty program (not all do). Show your QR code on each visit, collect stamps and earn rewards.';

  @override
  String get tour5Title => 'Favorites';

  @override
  String get tour5Desc => 'Save your favorite deals with the heart and find out about new deals from your favorite places.';

  @override
  String get ownerTour1Title => 'You\'re now a Promofy business!';

  @override
  String get ownerTour1Desc => 'Manage everything from the «My business» tab: your venues, promotions, advertising and stats.';

  @override
  String get ownerTour2Title => 'Create promotions';

  @override
  String get ownerTour2Desc => 'Publish regular, flash and birthday promos to attract customers to your business.';

  @override
  String get ownerTour3Title => 'Validate redemptions with QR';

  @override
  String get ownerTour3Desc => 'Scan the customer\'s code to validate their promotions and register their loyalty visits.';

  @override
  String get ownerTour4Title => 'Attract more customers';

  @override
  String get ownerTour4Desc => 'Create ad campaigns (splash, banner, featured and notifications) to reach more people near you.';

  @override
  String get ownerTour5Title => 'Measure and grow';

  @override
  String get ownerTour5Desc => 'Check your stats and average ticket, and manage your plan and add-ons whenever you need.';

  @override
  String get filterSectionSchedule => 'Hours';

  @override
  String get bandBreakfast => 'Breakfast';

  @override
  String get bandLunch => 'Lunch';

  @override
  String get bandDinner => 'Dinner';

  @override
  String get bandLateNight => 'Late night';

  @override
  String get visitasOwnerLoyaltyTitle => 'Loyalty program';

  @override
  String get visitasOwnerLoyaltySubtitle => 'Scan your customers\' QR to add stamps';

  @override
  String get visitasPickEstablishment => 'Choose the establishment';

  @override
  String get visitasNoEstablishments => 'You have no establishments';

  @override
  String get ownerTour6Title => 'Loyalty: your growth engine';

  @override
  String get ownerTour6Desc => 'Your stamp program makes customers COME BACK for their reward: more visits and more new customers by word of mouth.';

  @override
  String get ownerTour6Note => '📈 Loyalty members visit ~20% more often and spend ~20% more per visit (Circana).\n🔁 Acquiring a new customer costs 5–25× more than retaining one (Harvard Business Review).';
}
