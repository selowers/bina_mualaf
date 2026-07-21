class QuizQuestion {
  final String category;
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.category,
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

const List<QuizQuestion> quizQuestions = [
  QuizQuestion(
    category: 'Niat & Bacaan Sholat',
    question: 'Niat sholat Subuh terdiri dari berapa rakaat?',
    options: ['Satu rakaat', 'Dua rakaat', 'Tiga rakaat', 'Empat rakaat'],
    correctIndex: 1,
  ),
  QuizQuestion(
    category: 'Niat & Bacaan Sholat',
    question: 'Niat sholat Dzuhur terdiri dari berapa rakaat?',
    options: ['Dua rakaat', 'Tiga rakaat', 'Empat rakaat', 'Satu rakaat'],
    correctIndex: 2,
  ),
  QuizQuestion(
    category: 'Niat & Bacaan Sholat',
    question: 'Niat sholat Ashar terdiri dari berapa rakaat?',
    options: ['Dua rakaat', 'Tiga rakaat', 'Empat rakaat', 'Lima rakaat'],
    correctIndex: 2,
  ),
  QuizQuestion(
    category: 'Niat & Bacaan Sholat',
    question: 'Bacaan iftitah biasanya dibaca setelah?',
    options: ['Takbiratul ihram', 'Ruku', 'Setelah salam', 'Sebelum sujud'],
    correctIndex: 0,
  ),
  QuizQuestion(
    category: 'Niat & Bacaan Sholat',
    question: 'Bacaan ruku adalah?',
    options: [
      'Subhana Rabbiyal Adzimi',
      'Subhana Rabbiyal A’la',
      'Rabbighfirli',
      'Allahu Akbar',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    category: 'Tata Cara Wudhu',
    question: 'Langkah pertama dalam wudhu adalah?',
    options: [
      'Niat dan membasuh tangan hingga siku',
      'Mencuci muka dengan air',
      'Menyapu kepala',
      'Membasuh kaki',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    category: 'Tata Cara Wudhu',
    question: 'Bagian tubuh yang dibasuh sebelum kepala saat wudhu adalah?',
    options: ['Muka', 'Tangan hingga siku', 'Kaki', 'Hidung'],
    correctIndex: 1,
  ),
  QuizQuestion(
    category: 'Tata Cara Wudhu',
    question: 'Berapa kali kepala disapu saat wudhu menurut tata cara?',
    options: ['1 kali', '2 kali', '3 kali', '4 kali'],
    correctIndex: 0,
  ),
  QuizQuestion(
    category: 'Tata Cara Wudhu',
    question: 'Bagian tubuh yang terakhir dibasuh saat wudhu adalah?',
    options: ['Muka', 'Lengan', 'Tangan', 'Kaki sampai mata kaki'],
    correctIndex: 3,
  ),
  QuizQuestion(
    category: 'Tata Cara Wudhu',
    question: 'Doa setelah wudhu dibaca saat?',
    options: [
      'Sebelum mencuci muka',
      'Setelah menyelesaikan seluruh wudhu',
      'Sebelum masuk masjid',
      'Sebelum berniat',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    category: 'Rukun Iman & Islam',
    question: 'Rukun Islam kedua adalah?',
    options: ['Syahadat', 'Sholat', 'Zakat', 'Puasa'],
    correctIndex: 1,
  ),
  QuizQuestion(
    category: 'Rukun Iman & Islam',
    question: 'Rukun Islam ketiga adalah?',
    options: ['Zakat', 'Haji', 'Puasa', 'Syahadat'],
    correctIndex: 0,
  ),
  QuizQuestion(
    category: 'Rukun Iman & Islam',
    question: 'Rukun Iman kedua adalah percaya kepada?',
    options: ['Allah', 'Malaikat', 'Kitab', 'Rasul'],
    correctIndex: 1,
  ),
  QuizQuestion(
    category: 'Rukun Iman & Islam',
    question: 'Rukun Iman keempat adalah percaya kepada?',
    options: ['Kitab Suci', 'Rasul', 'Kiamat', 'Takdir'],
    correctIndex: 1,
  ),
  QuizQuestion(
    category: 'Rukun Iman & Islam',
    question: 'Rukun Iman keenam adalah percaya kepada?',
    options: ['Kitab Suci', 'Rasul', 'Kiamat', 'Qadha dan Qadar'],
    correctIndex: 3,
  ),
  QuizQuestion(
    category: 'Doa Keseharian',
    question: 'Doa sebelum makan memohon agar Allah?',
    options: [
      'Memberkahi rezeki yang diberikan',
      'Menghapus dosa setelah makan',
      'Memberi kekayaan lebih banyak',
      'Memberi kesehatan keluarga',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    category: 'Doa Keseharian',
    question: 'Doa sesudah makan adalah?',
    options: [
      'Alhamdulillahilladzi ath’amana wa saqana',
      'Bismillahirrahmanirrahim',
      'Allahu Akbar',
      'Subhana Rabbiyal A’la',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    category: 'Doa Keseharian',
    question: 'Doa naik kendaraan dimulai dengan?',
    options: [
      'Subhanalladzi sakhkhara lana',
      'Bismillahi tawakkaltu',
      'Alhamdulillahilladzi ath’amana',
      'Subhana Rabbiyal Adzimi',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    category: 'Doa Keseharian',
    question: 'Doa sebelum tidur adalah?',
    options: [
      'Bismika Allahumma ahya wa bismika amut',
      'Allahu Akbar',
      'Subhana Rabbiyal A’la',
      'Rabbighfirli',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    category: 'Doa Keseharian',
    question: 'Doa keluar rumah dimulai dengan?',
    options: [
      'Bismillahi tawakkaltu ala Allah',
      'Alhamdulillah',
      'Subhanalladzi sakhkhara lana',
      'Allahu Akbar',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    category: 'Murotal',
    question: 'Surat Al-Fatihah dikenal sebagai?',
    options: [
      'Surat pembuka',
      'Surat perang',
      'Surat terakhir',
      'Surat panjang',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    category: 'Murotal',
    question: 'Surat Al-Baqarah disebut juga?',
    options: ['Sapi Betina', 'Gunung', 'Rumah', 'Keluarga'],
    correctIndex: 0,
  ),
  QuizQuestion(
    category: 'Murotal',
    question: 'Surat Ali Imran berkaitan dengan?',
    options: [
      'Keluarga Imran',
      'Dua kali sujud',
      'Surat pendek',
      'Surat panjang',
    ],
    correctIndex: 0,
  ),
  QuizQuestion(
    category: 'Murotal',
    question: 'Surat An-Nisa berarti?',
    options: ['Wanita', 'Air', 'Langit', 'Keluarga'],
    correctIndex: 0,
  ),
  QuizQuestion(
    category: 'Murotal',
    question: 'Surat Al-Ma’idah memiliki arti?',
    options: ['Jamuan', 'Perjalanan', 'Pertempuran', 'Rahmat'],
    correctIndex: 0,
  ),
];
