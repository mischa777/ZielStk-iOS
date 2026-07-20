//
//  IAPRouter.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 12/3/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import Foundation

//MARK: CHANGE_IAP
enum IAPRouter {
    
    case tableName (name: String)
    case purchaseId (id: String)
    
    var productID: String {
        switch self {
        case .purchaseId(let purchaseID):
            return purchaseID
        case .tableName(let tableName):
            switch tableName {
            case "C-Test":
                return "de.zielstudienkolleg.c_test_generator"
            case "Ableitungen":
                return "de.zielstudienkolleg.ableitungen"
            case "Fakultat":
                return "de.zielstudienkolleg.fakultaet"
            case "Folgen und Reihen":
                return "de.zielstudienkolleg.folgen_und_reihen"
            case "Funktionsgraphen":
                return "de.zielstudienkolleg.funktionsgraphen"
            case "Geometrie":
                return "de.zielstudienkolleg.geometrie"
            case "Gleichungen":
                return "de.zielstudienkolleg.gleichungen"
            case "Gleichungen auflosen und umstellen":
                return "de.zielstudienkolleg.gleichungen_auflosen_und_umstellen"
            case "Gleichungssysteme":
                return "de.zielstudienkolleg.gleichungssysteme"
            case "Gleichungssysteme(Textaufgaben)":
                return "de.zielstudienkolleg.gleichungssysteme.textaufgaben"
            case "Grammatik":
                return "de.zielstudienkolleg.grammatik"
            case "Grenzwerte":
                return "de.zielstudienkolleg.grenzwerte"
            case "Größenordnung":
                return "de.zielstudienkolleg.groessenordnung"
            case "Integrale":
                return "de.zielstudienkolleg.integrale"
            case "Kettenbruche":
                return "de.zielstudienkolleg.kettenbrueche"
            case "Matrizen":
                return "de.zielstudienkolleg.matrizen"
            case "Mengen":
                return "de.zielstudienkolleg.mengen"
            case "Prozentaufgaben":
                return "de.zielstudienkolleg.prozentaufgaben"
            case "Quadratzahlen":
                return "de.zielstudienkolleg.quadratzahlen"
            case "Rechnen":
                return "de.zielstudienkolleg.rechnen"
            case "Ungewohnliche Aufgaben":
                return "de.zielstudienkolleg.ungewoehnliche_aufgaben"
            case "Ungleichungen":
                return "de.zielstudienkolleg.ungleichungen"
            case "Vektoren":
                return "de.zielstudienkolleg.vektoren"
            case "Vereinfachung von Termen mit Variablen":
                return "de.zielstudienkolleg.vereinfachung_von_termen_mit_variablen"
            case "Wahrscheinlichkeit":
                return "de.zielstudienkolleg.wahrscheinlichkeit"
            case "Wortschatz":
                return "de.zielstudienkolleg.wortschatz"
            case "Zahlensysteme":
                return "de.zielstudienkolleg.zahlensysteme"
            default:
                return "de.zielstudienkolleg.c_test_generator"
            }
        }
    }
    
    var firebaseTableName: String {
        switch self {
        case .tableName(let tableName):
            return tableName
        case .purchaseId(let purchaseID):
            switch purchaseID {
            case "de.zielstudienkolleg.c_test_generator":
                return "C-Test"
            case "de.zielstudienkolleg.ableitungen":
                return "Ableitungen"
            case "de.zielstudienkolleg.fakultaet":
                return "Fakultat"
            case "de.zielstudienkolleg.folgen_und_reihen":
                return "Folgen und Reihen"
            case "de.zielstudienkolleg.funktionsgraphen":
                return "Funktionsgraphen"
            case "de.zielstudienkolleg.geometrie":
                return "Geometrie"
            case "de.zielstudienkolleg.gleichungen":
                return "Gleichungen"
            case "de.zielstudienkolleg.gleichungen_auflosen_und_umstellen":
                return "Gleichungen auflosen und umstellen"
            case "de.zielstudienkolleg.gleichungssysteme":
                return "Gleichungssysteme"
            case "de.zielstudienkolleg.gleichungssysteme.textaufgaben":
                return "Gleichungssysteme(Textaufgaben)"
            case "de.zielstudienkolleg.grammatik":
                return "Grammatik"
            case "de.zielstudienkolleg.grenzwerte":
                return "Grenzwerte"
            case "de.zielstudienkolleg.groessenordnung":
                return "Größenordnung"
            case "de.zielstudienkolleg.integrale":
                return "Integrale"
            case "de.zielstudienkolleg.kettenbrueche":
                return "Kettenbruche"
            case "de.zielstudienkolleg.matrizen":
                return "Matrizen"
            case "de.zielstudienkolleg.mengen":
                return "Mengen"
            case "de.zielstudienkolleg.prozentaufgaben":
                return "Prozentaufgaben"
            case "de.zielstudienkolleg.quadratzahlen":
                return "Quadratzahlen"
            case "de.zielstudienkolleg.rechnen":
                return "Rechnen"
            case "de.zielstudienkolleg.ungewoehnliche_aufgaben":
                return "Ungewohnliche Aufgaben"
            case "de.zielstudienkolleg.ungleichungen":
                return "Ungleichungen"
            case "de.zielstudienkolleg.vektoren":
                return "Vektoren"
            case "de.zielstudienkolleg.vereinfachung_von_termen_mit_variablen":
                return "Vereinfachung von Termen mit Variablen"
            case "de.zielstudienkolleg.wahrscheinlichkeit":
                return "Wahrscheinlichkeit"
            case "de.zielstudienkolleg.wortschatz":
                return "Wortschatz"
            case "de.zielstudienkolleg.zahlensysteme":
                return "Zahlensysteme"
            default:
                return "C-Test"
            }
        }
    }
    
    var purchaseTableName: String {
        switch self {
        case .purchaseId:
            return "Mathematik"
        case .tableName(let tableName):
            switch tableName {
            case "C-Test", "Grammatik":
                return "Deutsch"
            default:
                return "Mathematik"
            }
        }
    }
}

extension IAPRouter {
    static let allProductIDs: [String] = [
        "de.zielstudienkolleg.ableitungen",
        "de.zielstudienkolleg.c_test_generator",
        "de.zielstudienkolleg.fakultaet",
        "de.zielstudienkolleg.folgen_und_reihen",
        "de.zielstudienkolleg.funktionsgraphen",
        "de.zielstudienkolleg.geometrie",
        "de.zielstudienkolleg.gleichungen",
        "de.zielstudienkolleg.gleichungen_auflosen_und_umstellen",
        "de.zielstudienkolleg.gleichungssysteme",
        "de.zielstudienkolleg.gleichungssysteme.textaufgaben",
        "de.zielstudienkolleg.grammatik",
        "de.zielstudienkolleg.grenzwerte",
        "de.zielstudienkolleg.groessenordnung",
        "de.zielstudienkolleg.integrale",
        "de.zielstudienkolleg.kettenbrueche",
        "de.zielstudienkolleg.matrizen",
        "de.zielstudienkolleg.mengen",
        "de.zielstudienkolleg.prozentaufgaben",
        "de.zielstudienkolleg.quadratzahlen",
        "de.zielstudienkolleg.rechnen",
        "de.zielstudienkolleg.ungewoehnliche_aufgaben",
        "de.zielstudienkolleg.ungleichungen",
        "de.zielstudienkolleg.vektoren",
        "de.zielstudienkolleg.vereinfachung_von_termen_mit_variablen",
        "de.zielstudienkolleg.wahrscheinlichkeit",
        "de.zielstudienkolleg.wortschatz",
        "de.zielstudienkolleg.zahlensysteme",
    ]
}
