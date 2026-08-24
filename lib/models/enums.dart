enum Rarity { comun, raro, epico, mitico, legendario }

enum TreeId { trigo, tomate, queso, hierbas, carne, pollo, pescado, fruta, cafe }

extension RarityLabel on Rarity {
  String get label {
    switch (this) {
      case Rarity.comun:
        return 'Común';
      case Rarity.raro:
        return 'Raro';
      case Rarity.epico:
        return 'Épico';
      case Rarity.mitico:
        return 'Mítico';
      case Rarity.legendario:
        return 'Legendario';
    }
  }

  int get stars {
    switch (this) {
      case Rarity.comun:
        return 1;
      case Rarity.raro:
        return 2;
      case Rarity.epico:
        return 3;
      case Rarity.mitico:
        return 4;
      case Rarity.legendario:
        return 5;
    }
  }
}

extension TreeIdLabel on TreeId {
  String get label {
    switch (this) {
      case TreeId.trigo:
        return 'Árbol del Trigo';
      case TreeId.tomate:
        return 'Árbol del Tomate';
      case TreeId.queso:
        return 'Árbol del Queso';
      case TreeId.hierbas:
        return 'Árbol de las Hierbas';
      case TreeId.carne:
        return 'Árbol de la Carne';
      case TreeId.pollo:
        return 'Árbol del Pollo';
      case TreeId.pescado:
        return 'Árbol del Pescado';
      case TreeId.fruta:
        return 'Árbol de la Fruta';
      case TreeId.cafe:
        return 'Árbol del Café';
    }
  }
}
