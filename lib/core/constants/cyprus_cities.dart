import '../../injection_container.dart';
import '../services/lookup_service.dart';

class CyprusCities {
  CyprusCities._();

  static List<String> get cities {
    final svc = sl<LookupService>();
    if (svc.isLoaded && svc.cityNames.isNotEmpty) {
      return svc.cityNames;
    }
    return _fallbackCities;
  }

  static Map<String, List<String>> get districts {
    final svc = sl<LookupService>();
    if (svc.isLoaded && svc.districtsByCityName.isNotEmpty) {
      return svc.districtsByCityName;
    }
    return _fallbackDistricts;
  }

  // Fallback data in case backend is unreachable
  static const List<String> _fallbackCities = [
    'Lefkoşa',
    'Girne',
    'Gazimağusa',
    'Güzelyurt',
    'İskele',
    'Lefke',
  ];

  static const Map<String, List<String>> _fallbackDistricts = {
    'Lefkoşa': [
      'Merkez',
      'Gönyeli',
      'Hamitköy',
      'Haspolat',
      'Alayköy',
      'Değirmenlik',
      'Akıncılar',
      'Meriç',
      'Kanlıköy',
    ],
    'Girne': [
      'Merkez',
      'Alsancak',
      'Lapta',
      'Karaoğlanoğlu',
      'Çatalköy',
      'Ozanköy',
      'Bellapais',
      'Esentepe',
      'Tatlısu',
      'Karşıyaka',
    ],
    'Gazimağusa': [
      'Merkez',
      'Maraş',
      'Tuzla',
      'Mormenekşe',
      'Mutluyaka',
      'Alasya',
      'Geçitkale',
      'Serdarlı',
      'Akdoğan',
      'Yeniboğaziçi',
    ],
    'Güzelyurt': [
      'Merkez',
      'Gaziveren',
      'Kalkanlı',
      'Serhatköy',
      'Bostancı',
      'Zümrütköy',
      'Aydınköy',
    ],
    'İskele': [
      'Merkez',
      'Boğaz',
      'Bafra',
      'Kaplıca',
      'Mehmetçik',
      'Büyükkonuk',
      'Yeniereköy',
      'Dipkarpaz',
      'Kumyalı',
    ],
    'Lefke': [
      'Merkez',
      'Gemikonağı',
      'Çamlıbel',
      'Yeşilırmak',
      'Cengizköy',
      'Doğancı',
    ],
  };
}
