class DiseaseData {
  static const Map<String, Map<String, String>> list = {
    'bacterial_spot': {
      'name': 'Bercak Bakteri',
      'description': 'Bercak kecil berair yang berubah gelap. Daun menguning dan rontok.',
      'treatment': '1. Pangkas daun terinfeksi.\n2. Semprot fungisida tembaga.\n3. Hindari siram dari atas.'
    },
    'early_blight': {
      'name': 'Bercak Kering (Early Blight)',
      'description': 'Bercak coklat dengan pola cincin seperti target panahan.',
      'treatment': '1. Sirkulasi udara harus baik.\n2. Pakai mulsa.\n3. Fungisida Mancozeb.'
    },
    'late_blight': {
      'name': 'Busuk Daun (Late Blight)',
      'description': 'Bercak besar basah kelabu/hijau gelap. Menyebar cepat saat lembab.',
      'treatment': '1. Musnahkan tanaman parah.\n2. Jaga kebun kering.\n3. Fungisida preventif.'
    },
    'leaf_mold': {
      'name': 'Kapang Daun',
      'description': 'Bercak kuning pucat di atas daun, bawahnya ada jamur halus zaitun.',
      'treatment': '1. Kurangi kelembaban.\n2. Ventilasi diperbaiki.\n3. Fungisida tembaga.'
    },
    'septoria_leaf_spot': {
      'name': 'Bercak Septoria',
      'description': 'Bercak bulat kecil banyak dengan pinggiran gelap dan pusat putih.',
      'treatment': '1. Buang daun sakit.\n2. Bersihkan gulma.\n3. Rotasi tanaman.'
    },
    'spotted_spider_mite': {
      'name': 'Tungau Laba-laba',
      'description': 'Bintik kuning halus di daun. Ada jaring halus jika parah.',
      'treatment': '1. Semprot air deras.\n2. Minyak Mimba (Neem Oil).'
    },
    'target_spot': {
      'name': 'Bercak Target',
      'description': 'Bercak coklat dengan lingkaran konsentris, mirip Early Blight tapi lebih kecil.',
      'treatment': '1. Jaga jarak tanam.\n2. Fungisida rutin.'
    },
    'yellow_leaf_curl_virus': {
      'name': 'Virus Kuning Keriting',
      'description': 'Daun mengecil, keriting ke atas, dan menguning.',
      'treatment': '1. Cabut tanaman.\n2. Basmi kutu kebul.\n3. Tidak ada obat kimia.'
    },
    'healthy': {
      'name': 'Tanaman Sehat',
      'description': 'Tanaman segar, hijau, mulus.',
      'treatment': 'Lanjutkan perawatan rutin (siram & pupuk).'
    },
  };
}