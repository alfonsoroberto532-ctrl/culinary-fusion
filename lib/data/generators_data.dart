import '../models/enums.dart';
import '../models/generator.dart';

/// 9 generadores iniciales, uno por árbol gastronómico.
/// PRODUCEN INMEDIATAMENTE al tocarlos. Nunca hay temporizadores de espera.
/// Al subir de nivel aumenta la VARIEDAD de lo que pueden producir
/// (nunca el tiempo de espera, porque no existe).
class GeneratorsData {
  static List<Generator> buildInitial() => [
        Generator(
          id: 'gen_huerto',
          name: 'Huerto',
          emoji: '🍅',
          treeId: TreeId.tomate,
          productionByLevel: {
            1: ['to1'],
            2: ['to1', 'to1', 'to2'],
            3: ['to1', 'to2', 'to2'],
            4: ['to1', 'to2', 'to3'],
          },
          upgradeCostByLevel: {2: 150, 3: 400, 4: 900},
        ),
        Generator(
          id: 'gen_molino',
          name: 'Molino',
          emoji: '🌾',
          treeId: TreeId.trigo,
          productionByLevel: {
            1: ['wh1'],
            2: ['wh1', 'wh1', 'wh2'],
            3: ['wh1', 'wh2', 'wh2'],
            4: ['wh1', 'wh2', 'wh3'],
          },
          upgradeCostByLevel: {2: 150, 3: 400, 4: 900},
        ),
        Generator(
          id: 'gen_lecheria',
          name: 'Lechería',
          emoji: '🥛',
          treeId: TreeId.queso,
          productionByLevel: {
            1: ['ch1'],
            2: ['ch1', 'ch1', 'ch2'],
            3: ['ch1', 'ch2', 'ch2'],
            4: ['ch1', 'ch2', 'ch3'],
          },
          upgradeCostByLevel: {2: 180, 3: 450, 4: 950},
        ),
        Generator(
          id: 'gen_jardin',
          name: 'Jardín de Hierbas',
          emoji: '🌿',
          treeId: TreeId.hierbas,
          productionByLevel: {
            1: ['he1'],
            2: ['he1', 'he1', 'he2'],
            3: ['he1', 'he2', 'he2'],
            4: ['he1', 'he2', 'he3'],
          },
          upgradeCostByLevel: {2: 150, 3: 400, 4: 900},
        ),
        Generator(
          id: 'gen_carniceria',
          name: 'Carnicería',
          emoji: '🥩',
          treeId: TreeId.carne,
          productionByLevel: {
            1: ['me1'],
            2: ['me1', 'me1', 'me2'],
            3: ['me1', 'me2', 'me2'],
            4: ['me1', 'me2', 'me3'],
          },
          upgradeCostByLevel: {2: 200, 3: 500, 4: 1000},
        ),
        Generator(
          id: 'gen_gallinero',
          name: 'Gallinero',
          emoji: '🐔',
          treeId: TreeId.pollo,
          productionByLevel: {
            1: ['po1'],
            2: ['po1', 'po1', 'po2'],
            3: ['po1', 'po2', 'po2'],
            4: ['po1', 'po2', 'po3'],
          },
          upgradeCostByLevel: {2: 220, 3: 550, 4: 1100},
        ),
        Generator(
          id: 'gen_muelle',
          name: 'Muelle de Pesca',
          emoji: '🐟',
          treeId: TreeId.pescado,
          productionByLevel: {
            1: ['fi1'],
            2: ['fi1', 'fi1', 'fi2'],
            3: ['fi1', 'fi2', 'fi2'],
            4: ['fi1', 'fi2', 'fi3'],
          },
          upgradeCostByLevel: {2: 220, 3: 550, 4: 1100},
        ),
        Generator(
          id: 'gen_huerto_frutal',
          name: 'Huerto Frutal',
          emoji: '🍎',
          treeId: TreeId.fruta,
          productionByLevel: {
            1: ['fr1'],
            2: ['fr1', 'fr1', 'fr2'],
            3: ['fr1', 'fr2', 'fr2'],
            4: ['fr1', 'fr2', 'fr3'],
          },
          upgradeCostByLevel: {2: 180, 3: 450, 4: 950},
        ),
        Generator(
          id: 'gen_tostadero',
          name: 'Tostadero de Café',
          emoji: '☕',
          treeId: TreeId.cafe,
          productionByLevel: {
            1: ['co1'],
            2: ['co1', 'co1', 'co2'],
            3: ['co1', 'co2', 'co2'],
            4: ['co1', 'co2', 'co3'],
          },
          upgradeCostByLevel: {2: 200, 3: 500, 4: 1000},
        ),
      ];
}
