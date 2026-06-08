const fs=require('fs');
const data={
 es:{tourSkip:'Saltar',tourNext:'Siguiente',tourStart:'Empezar',tourReplay:'Ver tutorial',
  tour1Title:'¡Bienvenido a Promofy!',tour1Desc:'Descubre las mejores promociones de restaurantes y entretenimiento cerca de ti.',
  tour2Title:'Explora cerca de ti',tour2Desc:'En Inicio y Lugares encuentras promos y negocios ordenados por distancia. Usa los filtros para hallar justo lo que se te antoja.',
  tour3Title:'Promos Relámpago',tour3Desc:'Ofertas por tiempo limitado. ¡Aprovéchalas antes de que se acaben!',
  tour4Title:'Sellos de lealtad',tour4Desc:'Muestra tu código QR en cada visita, junta sellos y gana recompensas en tus lugares favoritos.',
  tour5Title:'Favoritos y cumpleaños',tour5Desc:'Guarda tus promos favoritas con el corazón y recibe un regalo especial en tu cumpleaños.'},
 en:{tourSkip:'Skip',tourNext:'Next',tourStart:'Get started',tourReplay:'View tutorial',
  tour1Title:'Welcome to Promofy!',tour1Desc:'Discover the best deals from restaurants and entertainment near you.',
  tour2Title:'Explore near you',tour2Desc:'In Home and Places you'll find deals and businesses sorted by distance. Use filters to find exactly what you're craving.',
  tour3Title:'Flash deals',tour3Desc:'Limited-time offers. Grab them before they're gone!',
  tour4Title:'Loyalty stamps',tour4Desc:'Show your QR code on each visit, collect stamps and earn rewards at your favorite places.',
  tour5Title:'Favorites & birthday',tour5Desc:'Save your favorite deals with the heart and get a special gift on your birthday.'},
 de:{tourSkip:'Überspringen',tourNext:'Weiter',tourStart:'Los geht's',tourReplay:'Tutorial ansehen',
  tour1Title:'Willkommen bei Promofy!',tour1Desc:'Entdecke die besten Angebote von Restaurants und Unterhaltung in deiner Nähe.',
  tour2Title:'Entdecke in deiner Nähe',tour2Desc:'Unter Start und Orte findest du Angebote und Betriebe nach Entfernung sortiert. Nutze Filter, um genau das zu finden, worauf du Lust hast.',
  tour3Title:'Blitzangebote',tour3Desc:'Zeitlich begrenzte Angebote. Schnapp sie dir, bevor sie weg sind!',
  tour4Title:'Treuestempel',tour4Desc:'Zeige bei jedem Besuch deinen QR-Code, sammle Stempel und erhalte Belohnungen an deinen Lieblingsorten.',
  tour5Title:'Favoriten & Geburtstag',tour5Desc:'Speichere deine Lieblingsangebote mit dem Herz und erhalte ein besonderes Geschenk zu deinem Geburtstag.'}
};
for(const l of ['es','en','de']){
  const f=`lib/l10n/app_${l}.arb`;
  const o=JSON.parse(fs.readFileSync(f,'utf8'));
  Object.assign(o,data[l]);
  fs.writeFileSync(f,JSON.stringify(o,null,2)+'\n','utf8');
}
console.log('claves de tour agregadas (es/en/de)');
