$fn=200;
hAchse=17.5;

stegLaenge = 18.5;             // Bogenlaenge der Mittellinie
stegR      = 45;              // Radius der Mittellinie
stegW      = 3;                // Wandstaerke
stegH      = 5.5;               // Hoehe. Zwischen den Achs-Bunden (z 3 bis 14.5)
                               // sind 11.5 mm frei, das ist die Obergrenze.
stegWinkel = stegLaenge/stegR*180/PI;

federLaenge = 28;            // Bogenlaenge der Mittellinie
federR      = 60;              // Radius der Mittellinie, gleiche Kruemmungs-
                               // richtung wie der Steg
federStart  = 30;              // Startwinkel gegen die Steg-Tangente:
                               // die Feder laeuft zunaechst vom Steg weg
                               // und kruemmt sich dann zurueck
federVersatz = 2;              // Abzweigstelle als Bogenlaenge auf dem Steg,
                               // von der Achse aus gemessen
federW      = 1.4;             // Wandstaerke
federH      = stegH;           // Hoehe
kehleR      = 0.6;             // Radius der Verrundung an der Abzweigung

endH          = 5.5;             // Hoehe des Endstuecks, bewusst unabhaengig von
                               // stegH. Es bleibt auf hAchse/2 zentriert.
uebergang     = 6;             // Bogenlaenge, auf der der Steg von stegH auf
                               // endH auslaeuft
schnittWinkel = 30;            // 30°-Schraege am Endstueck
endDrehung    = 0;             // Drehung des Endstuecks um die Verbindungskante,
                               // negativ = im Uhrzeigersinn (Draufsicht)
endAnkerR     = stegR+stegW/2; // Radius, auf dem die Verbindungskante liegt
                               // (Aussenkante der Steg-Stirnflaeche)
endUeberlappung = 0.5;         // wie tief das Endstueck in den Steg eintaucht.
                               // Ein stumpfer Stoss mit exakt 0 waere geometrisch
                               // huebscher, haengt aber an der Polygonisierung
                               // des Bogens und reisst im Export auf.
endFase       = 1.5;          // Fase an der Aussenecke (12,12): Abstand von der
                               // Ecke auf der Kante y=12. Der Winkel ergibt sich,
                               // weil die Fase am Zylinderausschnitt beginnt.

// Bohrung fuer die Springfeder. Sie ersetzt die gedruckte Feder und soll in
// deren Richtung ziehen, deshalb zielt die Achse auf das freie Ende, das die
// gedruckte Feder hatte. Die Feder-Parameter oben bleiben dafuer stehen.
bohrD     = 5;                 // Durchmesser
bohrTiefe = 2.5;                 // Sackloch-Tiefe ab der Schraegflaeche
zapfenD   = 3;                 // Zentrierzapfen im Sackloch, muss in den
                               // Innendurchmesser der Feder passen
zapfenL   = bohrTiefe;         // Laenge ab dem Bohrungsgrund. Gleich bohrTiefe
                               // heisst: endet auf Hoehe des Eintrittspunkts
bohrPos   = 6.93;              // Eintritt: Abstand von der hinteren Ecke (0,12)
                               // entlang der Schraege (0 .. 12/cos(winkel))

function rot2(p, a) = [p[0]*cos(a)-p[1]*sin(a), p[0]*sin(a)+p[1]*cos(a)];

// Freies Ende der alten Feder (Mittellinie) in Weltkoordinaten
function federEnde() =
    let(t  = federLaenge/federR*180/PI,
        p  = rot2([federR*(1-cos(t)), federR*sin(t)], federStart),
        vw = federVersatz/stegR*180/PI)
    rot2([p[0]-stegR, p[1]], -vw) + [stegR, 0];

// Punkt aus dem lokalen System des Endstuecks nach Welt - dieselbe Kette wie
// beim Aufruf unten, nur zweidimensional nachgerechnet
function endToWorld(p) =
    rot2(rot2([p[0]-12*tan(schnittWinkel), p[1]-endUeberlappung],
              180+endDrehung) + [endAnkerR, 0],
         180-stegWinkel) + [stegR, 0];

bohrE  = [bohrPos*sin(schnittWinkel), 12-bohrPos*cos(schnittWinkel)];
bohrZ  = federEnde() - endToWorld(bohrE);   // Zielrichtung in Weltkoordinaten
bohrRi = atan2(bohrZ[1], bohrZ[0]) - (endDrehung-stegWinkel) + 180;
                               // ins lokale System zurueckgedreht, +180 weil
                               // die Bohrung ins Material hinein laeuft

module achse(h=hAchse) {
    w=8;
    d=2;
    
    cylinder(d=3, h=h);
    
    translate([0,0,h-w-d])
    cylinder(d=4.5, h=w);

    translate([0,0,d])
    cylinder(d=4.5, h=w);
}

// laenge = Bogenlaenge der Mittellinie, r = Radius der Mittellinie,
// w = Wandstaerke, h = Hoehe. Der Bogen startet auf der Achse (0,0)
// und laeuft nach +y.
module steg(laenge=stegLaenge, r=stegR, w=stegW, h=stegH) {
    winkel = laenge/r*180/PI;      // Bogenlaenge -> Oeffnungswinkel

    translate([r, 0, hAchse/2-h/2])
    rotate([0, 0, 180-winkel])
    rotate_extrude(angle=winkel, $fn=500)
    translate([r-w/2, 0])
    square([w, h]);
}

// Gleicher Aufbau wie der Steg, nur duenner und enger gekruemmt. Sie zweigt
// bei der Bogenlaenge "versatz" von der Steg-Mittellinie ab und startet dort
// um "start" gegen dessen Tangente gekippt.
module feder(laenge=federLaenge, r=federR, w=federW, h=federH,
             start=federStart, versatz=federVersatz) {
    vw = versatz/stegR*180/PI;     // Bogenwinkel der Abzweigstelle

    translate([stegR, 0, 0])       // Drehung um den Steg-Bogenmittelpunkt ...
    rotate([0, 0, -vw])            // ... auf die Abzweigstelle
    translate([-stegR, 0, 0])
    rotate([0, 0, start])          // Startwinkel gegen die Steg-Tangente
    steg(laenge, r, w, h);
}

// Laesst den Steg am Paddle-Ende von stegH auf endH auslaufen. Geschnitten
// wird mit zwei geneigten Ebenen, die am Bogenende genau auf Paddle-Hoehe
// liegen und nach hinten auf Steg-Hoehe ansteigen. In x ist der Schnitt auf
// die Steg-Breite begrenzt, damit die Feder unberuehrt bleibt.
module uebergangSchnitt(len=uebergang) {
    alpha = atan((stegH-endH)/2/len);

    // Der Steg endet 0.1 mm hoeher als das Paddle. Genau buendig waeren die
    // Deckflaechen koinzident und es entstuenden nicht-manifold-Kanten.
    module keil() {
        translate([0, 0, endH/2+0.1])
        rotate([alpha, 0, 0])
        translate([-4, 0, 0])
        cube([8, 40, 20]);
    }

    translate([stegR, 0, hAchse/2])
    rotate([0, 0, 180-stegWinkel])   // Frame am Bogenende, +y zeigt zurueck
    translate([stegR, 0, 0]) {
        keil();
        mirror([0, 0, 1]) keil();    // Gegenstueck unten
    }
}

// Steg und Feder als ein Koerper. Beide sind Prismen gleicher Hoehe, deshalb
// laesst sich die Kehle an der Abzweigung im 2D-Querschnitt verrunden:
// offset(+r) danach offset(-r) ist ein Closing - es fuellt konkave Ecken mit
// Radius r und laesst konvexe Ecken unveraendert.
// Wichtig: das Ergebnis ersetzt steg() und feder(), es wird NICHT dazu-
// unioniert. Sonst laegen zwei minimal verschiedene Polygonisierungen
// derselben Boegen aufeinander (rotate_extrude vs. projection+offset) und
// erzeugen Splitterflaechen - im Export waren das 291 nicht-manifold-Kanten.
module stegUndFeder(r=kehleR) {
    difference() {
        translate([0, 0, hAchse/2-stegH/2])
        linear_extrude(stegH)
        offset(r=-r) offset(r=r)
        projection() {
            steg();
            //feder();
        }

        if (stegH > endH) uebergangSchnitt();
    }
}

module endstueck(winkel=30, h=6, kanteDicke=1.2, kanteHoehe=1.2, kanteLaenge=11.3, kanteVersatz=0, fase=endFase) {
    schraege = 12/cos(winkel);     // 13.856 = volle Laenge der Schrägkante
    kanteY   = kanteLaenge*cos(winkel);    // y-Ausdehnung der Kante
    versatzY = kanteVersatz*cos(winkel);

    zylX = 21;                     // Zylinderausschnitt an der rechten Seite
    zylY = 4;
    zylD = 20;
    zylEnde = zylY + sqrt(pow(zylD/2, 2) - pow(12-zylX, 2));  // dort verlaesst
                                   // der Ausschnitt die Kante x=12

    difference() {
        cube([12, 12, h]);

        translate([0, 12, 0])          // Drehpunkt = linke obere Ecke
        rotate([0, 0, winkel])
        translate([-12, -20, -1])      // rechte Schnittfläche genau durch den Drehpunkt
        cube([12, 20, h+2]);

	   translate([zylX, zylY, 0])
	    	cylinder(d=zylD, h=20);

        // Fase an der Aussenecke (12,12): sie beginnt genau dort, wo der
        // Zylinderausschnitt die Kante x=12 verlaesst, und endet "fase" vor
        // der Ecke auf der Kante y=12. Der Winkel folgt aus den zwei Punkten.
        translate([0, 0, -1])
        linear_extrude(h+2)
        polygon([[12-fase, 12], [12, zylEnde], [14, zylEnde], [14, 14], [12-fase, 14]]);

        // Sackloch fuer die Springfeder, aus der Schraegflaeche heraus auf das
        // alte Federende gerichtet. Der Schneidzylinder startet 2 mm vor der
        // Flaeche, damit die schraege Muendung sauber ausbricht.
        translate([bohrE[0], bohrE[1], h/2])
        rotate([0, 0, bohrRi])
        rotate([0, 90, 0])
        translate([0, 0, -2])
        cylinder(d=bohrD, h=bohrTiefe+2);
    }

    // Zentrierzapfen, koaxial zum Sackloch. Steht am Bohrungsgrund und ragt
    // zapfenL nach aussen - deshalb nach dem difference() und nicht darin.
    // Das +1 steckt den Fuss 1 mm ins Vollmaterial. Endete er genau auf dem
    // Bohrungsgrund, waeren die beiden Stirnflaechen koplanar und es entstehen
    // Scheintunnel (Genus 17 statt 0).
    translate([bohrE[0], bohrE[1], h/2])
    rotate([0, 0, bohrRi])
    rotate([0, 90, 0])
    translate([0, 0, bohrTiefe-zapfenL])
    cylinder(d=zapfenD, h=zapfenL+1);

    // Kante an der Schrägkante, oben (z=h) und unten (z=-kanteHoehe).
    // Beide Enden sind parallel zur Rückseite abgeschnitten (y=const),
    // die Ausdehnung gibt der Beschnitt-Quader vor.
    // kanteVersatz = Abstand von der hinteren Ecke (0,12) entlang der Schräge.
    for (z = [-kanteHoehe, h])
    intersection() {
        translate([0, 12, 0])      // Drehpunkt = linke obere Ecke
        rotate([0, 0, winkel])
        translate([0, -schraege, z])
        cube([kanteDicke, schraege, kanteHoehe]);

        translate([0, 12-versatzY-kanteY, z])
        cube([12, kanteY, kanteHoehe]);
    }
}

achse();

stegUndFeder();

// Endstueck sitzt immer am freien Ende des Stegs: die vordere Ecke der
// Schraege (12*tan(winkel), 0) faellt auf die Verbindungskante der
// Steg-Stirnflaeche.
translate([stegR, 0, hAchse/2-endH/2])    // Bogenmittelpunkt, Endstueck mittig
rotate([0, 0, 180-stegWinkel])            // Richtung Bogenende
translate([endAnkerR, 0, 0])              // auf die Verbindungskante
rotate([0, 0, 180])                       // Vorderseite (y=0) auf die Stirnflaeche drehen
rotate([0, 0, endDrehung])                // ... und um die Verbindungskante weiterdrehen
translate([-12*tan(schnittWinkel), -endUeberlappung, 0])  // vordere Ecke der
                                          // Schraege auf diese Kante, um die
                                          // Ueberlappung in den Steg geschoben
endstueck(winkel=schnittWinkel, h=endH);