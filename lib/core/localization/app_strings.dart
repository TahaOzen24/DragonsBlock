import 'locale_manager.dart';

/// Centralized string catalog for the whole app.
///
/// Every user-facing string should live here (one getter per string, grouped by
/// feature) instead of being inlined as `isTr ? '...' : '...'` in widgets. This
/// gives a single source of truth for localization and makes adding a third
/// language a matter of extending `_s` and adding the getters.
class AppStrings {
  AppStrings._();

  /// Returns the [tr] translation for Turkish, otherwise the [en] translation.
  /// Extend this when a third language is added.
  static String _s(String tr, String en) =>
      LocaleManager.instance.isTurkish ? tr : en;

  // ─── Main Menu ────────────────────────────────────────────────────────────
  static String get playSurvivor => _s('OYUNA BAŞLA', 'PLAY SURVIVOR');
  static String get dungeon => _s('ZİNDAN', 'DUNGEON');
  static String get dailyRun => _s('GÜNLÜK GÖREV', 'DAILY RUN');
  static String get talents => _s('YETENEKLER', 'TALENTS');
  static String get themes => _s('TEMALAR', 'THEMES');
  static String get quests => _s('GÖREVLER', 'QUESTS');
  static String get bestScore => _s('EN YÜKSEK', 'BEST');
  static String get freeReward => _s('ÜCRETSİZ', 'FREE');
  static String get heroTitle => _s('Kozmik Rünler ve Güçler', 'Cosmic Runes & Powers');
  static String get heroSubtitle => _s('Blokları yerleştir, komboları patlat, hayatta kal!', 'Place blocks, trigger combos, survive!');

  // Quick menu & tabs.
  static String get quickMenuTitle => _s('⚙️ HIZLI MENÜ & AYARLAR', '⚙️ QUICK MENU & SETTINGS');
  static String get jukeboxTitle => _s('Rünik Müzik Konsolu (Jukebox)', 'Runic Jukebox Soundscapes');
  static String get audioSettingsTitle => _s('Ses, Titreşim & Ekran Ayarları', 'Audio, Haptics & Screen Settings');
  static String get howToPlayTitle => _s('Nasıl Oynanır & Oyun Rehberi', 'How to Play & Guide');
  static String get changeLanguageTitle => _s('Dili Değiştir (Language: English)', 'Change Language (Dil: Türkçe)');
  static String get heroBadge => _s('ŞAMPİYON', 'HERO');
  static String get highScoreLabel => _s('EN YÜKSEK SKOR:', 'HIGH SCORE:');
  static String get battleNow => _s('SAVAŞA BAŞLA', 'BATTLE NOW');
  static String get battlePassShort => _s('Savaş Bileti', 'Battle Pass');
  static String get questsShort => _s('Görevler', 'Quests');
  static String get dailyStreakShort => _s('7 Günlük Seri', 'Daily Streak');

  static String get tabBattle => _s('Savaş', 'Battle');
  static String get tabSanctuary => _s('Mistik', 'Sanctuary');
  static String get tabRealms => _s('Diyarlar', 'Realms');
  static String get tabBazaar => _s('Pazar', 'Bazaar');

  // Sanctuary tab.
  static String get sanctuaryHeader => _s('🔮 MİSTİK OCAK & SİMYA', '🔮 MYSTIC SANCTUARY');
  static String get sanctuarySubtitle => _s('Rünlerini güçlendir, iksirler üret ve yadigarları kuşan', 'Upgrade runes, brew potions & craft relics');
  static String get enchantmentForge => _s('Rünik Efsunlama Ocağı', 'Enchantment Forge');
  static String get enchantmentForgeSub => _s('8 Matris Mührü ve 3 Soket ile güçlendirmeler', '8 Matrix Sigils & 3 Socket enhancements');
  static String get alchemyLab => _s('Mistik Rün Simyası', 'Runic Alchemy Lab');
  static String get alchemyLabSub => _s('Yıldız Tozu dönüştürme & 4 Taktiksel Maç İksiri', 'Stardust transmutation & 4 Tactical Elixirs');
  static String get arcaneScrolls => _s('Kadim Savaş Parşömenleri & Füzyon', 'Arcane Scrolls & Fusion Forge');
  static String get equipScroll => _s('Parşömen Kuşan', 'Equip Scroll');
  static String get tacticalSeals => _s('Taktiksel Mühürler', 'Tactical Seals');
  static String get constellations => _s('Astral Yıldız Haritası & Takımyıldızlar', 'Astral Star Chart & Constellations');
  static String get artifactVault => _s('Efsanevi Yadigar Kasası', 'Artifact Vault');
  static String get runeOracle => _s('Kozmik Rün Kehaneti', 'Daily Rune Oracle');
  static String get runeOracleSub => _s('Günün Tarot Falını Çek ve Kutsama Kazan', 'Draw Today’s Tarot Fortune & Blessings');
  static String get petSanctuary => _s('Rünik Yoldaşlar Korunağı', 'Familiars & Pets Sanctuary');
  static String get talentMastery => _s('Yetenek Ağacı', 'Talent Mastery');
  static String get talentMasterySub => _s('8 Kalıcı savaş yeteneği yükseltmesi', '8 Permanent combat masteries');
  static String get evolveFeed => _s('Evrim & Besleme', 'Evolve & Feed');
  static String get nodesLit => _s('Düğüm Açık', 'Stars Lit');
  static String get ancientConstellations => _s('4 Kadim Takımyıldız', '4 Ancient Constellations');
  static String get setsActive => _s('Set Aktif', 'Sets Active');
  static String get permanentBuffs => _s('Kalıcı Pasif Güçler', 'Permanent Buffs');

  // Realms tab.
  static String get realmsHeader => _s('🏰 DİYARLAR & SEFERLER', '🏰 REALMS & EXPEDITIONS');
  static String get realmsSubtitle => _s('Loncanla patronu bas, keşiflere çık ve canavarları öğren', 'Raid World Boss, launch outposts & study monsters');
  static String get weeklyTournament => _s('Haftalık Elementel Turnuva', 'Weekly Glory Tournament');
  static String get season => _s('Sezon', 'Season');
  static String get guildWorldBoss => _s('Rünik Loncalar & Dünya Patronu', 'Guilds & World Boss Raid');
  static String get guildWorldBossSub => _s('Ignarok Baskını • Kolektif hasar ve aşama sandıkları', 'Raid Ignarok • Collective boss chests');
  static String get guildConquest => _s('Lonca Bölge Fetihleri (Klan Savaşı)', 'Guild Territory Conquest Wars');
  static String get territoriesCaptured => _s('Bölge Fethedildi', 'Captured');
  static String get passiveClanPerks => _s('Lonca Güçlendirmeleri', 'Passive Clan Perks');
  static String get expeditions => _s('Ejderha Keşif Seferleri', 'Dragon Expeditions');
  static String get expeditionsSub => _s('4 Pasif Zamanlı Keşif Bölgesi • Otomatik Ganimet', '4 Timed Outposts • Automatic Offline Loot');
  static String get bestiary => _s('Canavar & Boss Kodeksi', 'Runic Bestiary Lore');
  static String get bestiarySub => _s('Keşif • Zayıflık ve strateji rehberi', 'Discovered • Monster guide');
  static String get lunarFestival => _s('Kozmik Ay Festivali', 'Cosmic Lunar Festival');
  static String get lunarFestivalSub => _s('Sınırlı Süreli Etkinlik • Ay Fenerleri ve Pazar', 'Live Event • Lanterns & Seasonal Bazaar');
  static String get hallOfFame => _s('Şeref Kürsüsü & Unvanlar', 'Hall of Fame Titles');
  static String get hallOfFameSub => _s('Prestij Seviyesi & 8 Efsanevi Başarım Unvanı', 'Prestige Rank & 8 Unlockable Titles');
  static String get leaderTitle => _s('Liderlik Tablosu & Ligler', 'Leaderboards & Leagues');
  static String get leaderSub => _s('Dünya sıralaması ve haftalık kupa ligleri', 'Global rankings & weekly leagues');
  static String get achvTitle => _s('Başarımlar & Rozetler', 'Achievements & Badges');
  static String get achvSub => _s('30+ Özel başarım ve altın ödülleri', '30+ Challenges & Gold milestones');

  // Bazaar tab.
  static String get bazaarHeader => _s('🛒 PAZAR & ÖDÜLLER', '🛒 BAZAAR & REWARDS');
  static String get bazaarSubtitle => _s('Görünümler aç, çarkı çevir ve AFK kasasını topla', 'Unlock skins, spin the wheel & claim idle bank');
  static String get customizationShop => _s('Kişiselleştirme & Görünüm Mağazası', 'Customization & Skin Shop');
  static String get customizationShopSub => _s('Blok kaplamaları, tahta desenleri & patlama VFX', 'Block skins, boards & clear VFX');
  static String get particleLab => _s('Parçacık Laboratuvarı & Efektler', 'Particle FX Lab & VFX Mixer');
  static String get liveSandbox => _s('Canlı Tuval', 'Live Sandbox');
  static String get luckyWheel => _s('Kozmik Şans Çarkı', 'Lucky Fortune Wheel');
  static String get luckyWheelSub => _s('Günlük ücretsiz çevirme ve devasa ödüller', 'Daily free spin & jackpot rewards');
  static String get idleVault => _s('AFK Kasa (Idle Vault)', 'Idle Gold Vault');
  static String get idleVaultOffline => _s('Çevrimdışı Altın Üretimi', 'Offline Gold Generation');
  static String get collect => _s('Topla', 'Claim');
  static String get leaderboards => _s('Liderlik Tablosu & Ligler', 'Leaderboards & Leagues');
  static String get leaderboardsSub => _s('Dünya sıralaması ve haftalık kupa ligleri', 'Global rankings & weekly leagues');
  static String get achievementsBadges => _s('Başarımlar & Rozetler', 'Achievements & Badges');
  static String get achievementsBadgesSub => _s('30+ Özel başarım ve altın ödülleri', '30+ Challenges & Gold milestones');

  // ─── Bottom Navigation ──────────────────────────────────────────────────
  static String get navShop => _s('MAĞAZA', 'SHOP');
  static String get navCollection => _s('KOLEKSİYON', 'COLLECTION');
  static String get navHome => _s('ANA SAYFA', 'HOME');
  static String get navPlay => _s('OYNA', 'PLAY');
  static String get navDragon => _s('EJDERHA', 'DRAGON');
  static String get navLeaderboard => _s('LİDERLİK', 'LEADERBOARD');
  static String get navClub => _s('KULÜP', 'CLUB');
  static String get localPracticeRanking => _s('YEREL ANTRENMAN SIRALAMASI', 'LOCAL PRACTICE RANKING');
  static String get claimWeeklyChest => _s('HAFTALIK SANDIĞI AL', 'CLAIM WEEKLY CHEST');
  static String get weeklyChestClaimed => _s('BU HAFTA ALINDI', 'CLAIMED THIS WEEK');
  static String get comingSoon => _s('YAKINDA', 'COMING SOON');
  static String get useThemePalette => _s('TEMAYA DÖN', 'USE THEME');
  static String get dragonMaxLevel => _s('Maksimum seviye — besleme kapalı', 'Max level — feeding locked');
  static String get unlockEggAction => _s('YUMURTAYI AÇ', 'UNLOCK EGG');
  static String get selectDragonAction => _s('SEÇ', 'SELECT');
  static String get notEnoughGold => _s('Yeterli altın yok!', 'Not enough gold!');

  // ─── Collection Tab ────────────────────────────────────────────────────
  static String get collectionTalent => _s('Yetenek', 'Talent');
  static String get collectionConstellation => _s('Takımyıldız', 'Constellation');
  static String get collectionEnchantment => _s('Efsun', 'Enchant');
  static String get collectionArtifact => _s('Yadigar', 'Artifact');
  static String get collectionAlchemy => _s('Simya', 'Alchemy');
  static String get collectionPet => _s('Yoldaş', 'Companion');

  // ─── Leaderboard Tab ───────────────────────────────────────────────────
  static String get weeklyRanking => _s('HAFTALIK SIRALAMA', 'WEEKLY RANKING');
  static String get viewAll => _s('TÜMÜNÜ GÖR ›', 'VIEW ALL ›');
  static String get ghostDuelArena => _s('HAYALET DÜELLO ARENASI', 'GHOST DUEL ARENA');
  static String get ghostDuelSubtitle => _s('Rakip Skoru Yenmeye Çalış', 'Beat Your Rival\'s Score');
  static String get tabDuel => _s('DÜELLO', 'DUEL');
  static String get honorSeasonEvents => _s('ŞEREF & SEZON ETKİNLİKLERİ', 'HONOR & SEASON EVENTS');
  static String get tabBattlePass => _s('Savaş Bileti', 'Battle Pass');
  static String get honorPodium => _s('Şeref Kürsüsü', 'Hall of Fame');
  static String get tabAchievements => _s('Başarımlar', 'Achievements');
  static String get tabRuneProphecy => _s('Rün Kehaneti', 'Rune Oracle');
  static String get dailyFortune => _s('Günün Tarot Falı', 'Daily Fortune');
  static String get tabRewards => _s('ÖDÜLLER', 'REWARDS');
  static String get tabTitles => _s('UNVANLAR', 'TITLES');
  static String get tabBadges => _s('ROZETLER', 'BADGES');
  static String get tabOracle => _s('KEHANET', 'ORACLE');
  static String get tabWeeklyLeague => _s('Ligi', 'League');
  static String get tabYourScore => _s('Puanın', 'Score');
  static String get tabTarget => _s('Hedef', 'Target');
  static String get tabYou => _s('SEN', 'YOU');

  // ─── Club Tab ──────────────────────────────────────────────────────────
  static String get clanRaids => _s('KLAN SEFERLERİ & KEŞİF', 'CLAN RAIDS & EXPEDITION');
  static String get joinRaidAction => _s('BASKINA GİR', 'JOIN RAID');
  static String get territoryConquest => _s('Bölge Fetihleri', 'Territory Conquest');
  static String get conquered => _s('Fethedildi', 'Conquered');
  static String get tabExpedition => _s('Keşif', 'Expedition');
  static String get sendHero => _s('Kahraman Gönder, Altın Kazan', 'Send Hero, Earn Gold');
  static String get tabScrollFusion => _s('Savaş Parşömeni', 'Scroll Fusion');
  static String get tabFusionBoosters => _s('Füzyon & Güçlendirmeler', 'Fusion & Boosters');
  static String get tabCosmicFestival => _s('Kozmik Ay Festivali', 'Cosmic Festival');
  static String get tabLimitedEvent => _s('Sınırlı Etkinlik', 'Limited Event');
  static String get tabConquest => _s('FETİH', 'CONQUEST');
  static String get tabExplore => _s('KEŞİF', 'EXPLORE');
  static String get tabFusion => _s('FÜZYON', 'FUSION');
  static String get tabFestival => _s('FESTİVAL', 'FESTIVAL');
  static String get tabMembers => _s('Üye', 'Members');
  static String get tabDetail => _s('DETAY', 'DETAIL');
  static String get tabJoin => _s('KATIL', 'JOIN');
  static String get weeklyVictoryTournament => _s('HAFTALIK ZAFER TURNUVASI', 'WEEKLY VICTORY TOURNAMENT');

  // ─── Game Screen & HUD ────────────────────────────────────────────────────
  static String get energy => _s('ENERJİ', 'ENERGY');
  static String get combo => _s('KOMBO', 'COMBO');
  static String get best => _s('REKOR', 'BEST');
  static String get pause => _s('DURAKLAT', 'PAUSE');
  static String get resume => _s('DEVAM ET', 'RESUME');
  static String get restart => _s('YENİDEN BAŞLA', 'RESTART');
  static String get quit => _s('ÇIKIŞ', 'QUIT');
  static String get moveUndone => _s('⏪ HAMLE GERİ ALINDI!', '⏪ MOVE UNDONE!');
  static String get noMoveToUndo => _s('Geri alınacak hamle yok!', 'No move to undo!');
  static String get needEnergy => _s('Daha Fazla Enerji Lazım!', 'Need More Energy!');
  static String get gameOver => _s('OYUN BİTTİ', 'GAME OVER');
  static String get finalScore => _s('Toplam Skor', 'Final Score');
  static String get revived => _s('❤️ ANKA KÜLLERİNDEN DOĞDUN!', '❤️ REVIVED FROM ASHES!');
  static String get claimReward => _s('ÖDÜLÜ AL', 'CLAIM REWARD');
  static String get doubleReward => _s('2X KAZANÇ (REKLAM)', '2X REWARDS (AD)');

  // ─── Power-Ups ────────────────────────────────────────────────────────────
  static String get hammerName => _s('Balyoz', 'Hammer');
  static String get hammerDesc => _s('Tahtadaki seçtiğin 1 bloğu kırar', 'Smash & clear any 1 block on the grid');
  static String get undoName => _s('Geri Al', 'Undo');
  static String get undoDesc => _s('Son yaptığın hamleyi geri sarar', 'Rewind & undo your last block placement');
  static String get rotateName => _s('Çevir', 'Rotate');
  static String get rotateDesc => _s('Bloğu 90 derece döndürür', 'Rotate a shape 90 degrees');
  static String get rerollName => _s('Yenile', 'Reroll');
  static String get rerollDesc => _s('Mevcut 3 bloğu yeniler', 'Reroll all 3 current shapes');
  static String get smashPrompt => _s('Kırmak istediğin bloğa dokun! 🔨', 'Tap any block to smash! 🔨');
  static String get rocketPrompt => _s('Hedef hücreye dokun! 🚀', 'Tap a cell for the rocket! 🚀');
  static String get boosterEmpty => _s('Bu güçlendirici kalmadı!', 'No boosters left!');
  static String get rerollLimit => _s('Bu oyunda yenileme hakkın bitti!', 'No rerolls left this game!');
  static String get nextQueueLabel => _s('SIRADA', 'NEXT');

  // ─── Game Modes ───────────────────────────────────────────────────────────
  static String get modesPortal => _s('OYUN MODLARI PORTALI', 'GAME MODES PORTAL');
  static String get selectMode => _s('Oynamak istediğin modu seç', 'Select a game mode to play');
  static String get classicSurvivor => _s('Klasik Hayatta Kalma', 'Classic Survivor');
  static String get classicSurvivorSub => _s('Boss istilaları, rün reaksiyonları & 2X Fever', 'Boss raids, rune reactions & 2X Fever');
  static String get coreBadge => _s('ANA MOD', 'CORE');
  static String get infiniteDungeon => _s('Sonsuz Zindan (Abyss)', 'Infinite Dungeon (Abyss)');
  static String get infiniteDungeonSub => _s('16+ Sonsuz kat, 6 biyom ve kademeli boss odaları', '16+ Endless floors, 6 biomes & bosses');
  static String get roguelikeBadge => _s('ROGUELIKE', 'ROGUELIKE');
  static String get runicSpire => _s('Rünik Kule (Spire)', 'Runic Spire of Ascension');
  static String get floor => _s('Kat', 'Floor');
  static String get spireMutators => _s('Değişken taktiksel kural mutatörleri', 'Tactical mutators');
  static String get trialBadge => _s('MEYDAN OKUMA', 'TRIAL');
  static String get ghostDuel => _s('Hayalet Düello (PvP)', 'Ghost Duel (PvP)');
  static String get asyncPvp => _s('Asenkron rakip mücadelesi', 'Async PvP');
  static String get rankedBadge => _s('LİG DERECELİ', 'RANKED');
  static String get puzzleMaster => _s('Bulmaca Ustası', 'Puzzle Master');
  static String get handcraftedStages => _s('El yapımı zeka aşaması', 'Handcrafted stages');
  static String get stagesBadge => _s('30 BÖLÜM', '30 STAGES');
  static String get blitzMode => _s('60s Hızlı Hücum (Blitz)', '60s Blitz Attack');
  static String get blitzModeSub => _s('60 saniyede maksimum kombo ve hız rekoru', '60 seconds max combo speed run');
  static String get speedBadge => _s('ZAMANA KARŞI', 'SPEED');
  static String get zenMode => _s('Zen Rahatlama', 'Zen Chill');
  static String get zenModeSub => _s('Sıfır stres, can sınırı yok, huzurlu blok akışı', 'Zero stress, endless calming block flow');
  static String get chillBadge => _s('RAHATLAMA', 'CHILL');
  static String get dailyChallengeMode => _s('Günün Meydan Okuması', 'Daily Challenge');
  static String get dailyChallengeModeSub => _s('24 saatlik özel kural mutatörü ve ekstra ödüller', '24h special mutator and extra rewards');
  static String get dailyBadge => _s('GÜNLÜK', 'DAILY');

  // ─── Game Over & Results ──────────────────────────────────────────────────
  static String get newRecord => _s('YENİ REKOR!', 'NEW RECORD!');
  static String get legendaryRun => _s('EFSANEVİ KOŞU!', 'LEGENDARY RUN!');
  static String get runTerminated => _s('OYUN SONA ERDİ', 'RUN TERMINATED');
  static String get bestScoreStat => _s('En Yüksek Skor', 'Best Score');
  static String get linesClearedStat => _s('Temizlenen Çizgi', 'Lines Cleared');
  static String get shardsEarnedStat => _s('Kazanılan Altın', 'Shards Earned');
  static String get reviveContinue => _s('HAYATA DÖN (1 CAN)', 'REVIVE & CONTINUE');
  static String get doubleShards => _s('2X KAZANÇ (REKLAM)', 'DOUBLE SHARDS (AD)');
  static String get shareScoreCard => _s('SKOR KARTINI PAYLAŞ 📸', 'SHARE SCORE CARD 📸');
  static String get menu => _s('MENÜ', 'MENU');
  static String get playAgain => _s('TEKRAR OYNA', 'PLAY AGAIN');

  // ─── Share Score ──────────────────────────────────────────────────────────
  static String get rankGrandmaster => _s('⚡ EFSANEVİ RÜN HÜKÜMDARI', '⚡ GRANDMASTER RUNESMITH');
  static String get rankMasterOfRunes => _s('🔥 BAŞBÜYÜCÜ RUNEMASTER', '🔥 MASTER OF RUNES');
  static String get rankMysticBlast => _s('💎 MİSTİK PATLAMA UZMANI', '💎 MYSTIC BLAST ARCHON');
  static String get rankRunicApprentice => _s('🌟 RÜN ÇIRAĞI', '🌟 RUNIC APPRENTICE');
  static String get totalScore => _s('TOPLAM SKOR', 'FINAL SCORE');
  static String get maxCombo => _s('🔥 Maks Kombo', '🔥 Max Combo');
  static String get copiedToClipboard => _s('📋 Skor metni panoya kopyalandı!', '📋 Score text copied to clipboard!');
  static String get copyShareScore => _s('SKORU KOPYALA & PAYLAŞ', 'COPY & SHARE SCORE');

  static String shareScoreText(int score, String rankTitle) => _s(
        '🎮 Runic Blast oyununda $score puan yaptım! Rütbem: $rankTitle 👑. Benim rekorumu geçebilir misin?',
        '🎮 I scored $score in Runic Blast! Rank: $rankTitle 👑. Can you beat my record?',
      );

  // ─── Relic / Blessing ─────────────────────────────────────────────────────
  static String get relicMilestone => _s('EFSANEVİ RELIC SEÇİMİ', 'RELIC MILESTONE');
  static String get relicMilestoneSub => _s(
        'Bu oyunu güçlendirecek bir kutsal emanet seç!',
        'Choose a powerful synergy relic to augment this run!',
      );

  // ─── Settings ─────────────────────────────────────────────────────────────
  static String get settings => _s('AYARLAR', 'SETTINGS');
  static String get language => _s('Dil / Language', 'Language / Dil');
  static String get languageSubtitle => _s('Türkçe seçili', 'English selected');
  static String get music => _s('Müzik', 'Music');
  static String get musicSubtitle => _s('Lo-Fi arka plan melodisi', 'Lo-Fi ambient melody loop');
  static String get soundFx => _s('Ses Efektleri', 'Sound FX');
  static String get soundFxSubtitle => _s('Blok ve kombo sesleri', 'Block & combo sound effects');
  static String get haptics => _s('Titreşim (Haptik)', 'Haptic Feedback');
  static String get hapticsSubtitle => _s('Dokunma ve patlama titreşimleri', 'Vibrations on clears & drops');
  static String get screenShake => _s('Ekran Sarsıntısı', 'Screen Shake');
  static String get screenShakeSubtitle => _s('Patlamalarda dinamik efekt', 'Dynamic impact on explosions');
  static String get batterySaver => _s('Pil Tasarrufu', 'Battery Saver');
  static String get batterySaverSubtitle => _s('Arka plan efektlerini azaltır', 'Reduces background effects');

  // ─── Quests & Rewards ─────────────────────────────────────────────────────
  static String get dailyRewards => _s('7 GÜNLÜK ÖDÜLLER', '7-DAY REWARDS');
  static String get dailyRewardsDesc => _s('Her gün giriş yaparak altın ve ödülleri topla!', 'Log in daily to claim escalating rewards!');
  static String get claim => _s('AL', 'CLAIM');
  static String get claimed => _s('ALINDI', 'CLAIMED');
  static String get day => _s('Gün', 'Day');
  static String get dailyQuests => _s('GÜNLÜK GÖREVLER', 'DAILY QUESTS');
  static String get achievements => _s('BAŞARIMLAR', 'ACHIEVEMENTS');

  // ─── Boss & Dungeon ───────────────────────────────────────────────────────
  static String get bossDungeon => _s('BOSS ZİNDANI', 'BOSS DUNGEON');
  static String get victory => _s('ZAFER!', 'VICTORY!');
  static String get defeated => _s('YENİLGİ', 'DEFEATED');
  static String get bossAttackIn => _s('⚔️ Boss Saldırısı:', '⚔️ Boss Attack in:');
  static String get placements => _s('Hamle', 'Placements');
  static String get tryAgain => _s('TEKRAR DENE', 'TRY AGAIN');
  static String get returnToMap => _s('HARİTAYA DÖN', 'RETURN TO MAP');

  // ─── Shop & Themes ────────────────────────────────────────────────────────
  static String get shop => _s('MAĞAZA', 'SHOP');
  static String get boardThemes => _s('TAHTA VE BLOK TEMALARI', 'BOARD & TILE SKINS');
  static String get blockStudio => _s('BLOK & TEMA STÜDYOSU', 'BLOCK & THEME STUDIO');
  static String get blockPresets => _s('HAZIR TEMALAR', 'PRESET THEMES');
  static String get paletteMixer => _s('PALET MİKSERİ (MIX)', 'PALETTE MIXER');
  static String get blockMaterial => _s('BLOK MATERYALİ', 'BLOCK MATERIAL');
  static String get freeShardsTitle => _s('ÜCRETSİZ GÜNLÜK ALTIN', 'FREE DAILY SHARDS');
  static String get freeShardsDesc => _s('Hemen +100 bonus altın kazan', 'Claim +100 bonus shards now');
  static String get equipped => _s('KULLANILIYOR', 'EQUIPPED');
  static String get equip => _s('KULLAN', 'EQUIP');
  static String get unlock => _s('KİLİDİ AÇ', 'UNLOCK');

  // ─── Common Actions & States ──────────────────────────────────────────────
  static String get locked => _s('KİLİTLİ', 'LOCKED');
  static String get equipSigil => _s('KUŞAN', 'EQUIP');
  static String get equippedSigil => _s('KUŞANILDI', 'EQUIPPED');
  static String get activeCheck => _s('AKTİF ✓', 'ACTIVE ✓');
  static String get activeLabel => _s('AKTİF', 'ACTIVE');
  static String get fight => _s('SAVAŞ', 'FIGHT');
  static String get exit => _s('ÇIKIŞ', 'EXIT');
  static String get next => _s('SONRAKİ ➔', 'NEXT ➔');
  static String get retry => _s('TEKRAR DENE 🔄', 'RETRY 🔄');
  static String get retryShort => _s('TEKRAR 🔄', 'RETRY 🔄');
  static String get mainMenu => _s('MENÜYE DÖN', 'MAIN MENU');
  static String get start => _s('BAŞLA', 'START');
  static String get deploy => _s('GÖNDER', 'DEPLOY');
  static String get select => _s('SEÇ', 'SELECT');
  static String get selectArrow => _s('SEÇ ➔', 'SELECT ➔');
  static String get insufficientShards => _s('❌ Yetersiz Altın Şarapnel!', '❌ Insufficient Gold Shards!');
  static String get cancel => _s('İPTAL', 'CANCEL');
  static String get insufficientLanterns => _s('❌ Yetersiz Ay Feneri!', '❌ Insufficient Lunar Lanterns!');
  static String get insufficientStardust => _s('❌ Yetersiz Yıldız Tozu! Dönüştürme yapın.', '❌ Insufficient Stardust! Transmute first.');
  static String get insufficientGoldStardust => _s('❌ Yetersiz Altın veya Yıldız Tozu!', '❌ Insufficient Gold or Stardust!');
  static String get empty => _s('Boş', 'Empty');
  static String get maxLevel => _s('MAKS DÜZEY', 'MAX LEVEL');
  static String get maximum => _s('MAKSİMUM', 'MAX');
  static String get playing => _s('ÇALIYOR', 'PLAYING');
  static String get playSel => _s('SEÇ', 'PLAY');
  static String get openGift => _s('AÇ 🎁', 'OPEN 🎁');
  static String get join => _s('KATIL', 'JOIN');
  static String get member => _s('ÜYESİN', 'MEMBER');
  static String get captured => _s('Fethedildi', 'Captured');
  static String get claimGift => _s('TOPLA 🎁', 'CLAIM 🎁');
  static String get claimedCheck => _s('ALINDI ✓', 'CLAIMED ✓');
  static String get unlockedCheck => _s('AÇILDI ✓', 'UNLOCKED ✓');
  static String get upgrade => _s('GELİŞTİR', 'UPGRADE');
  static String get transmute => _s('DÖNÜŞTÜR', 'TRANSMUTE');
  static String slot(int n) => _s('Yuva $n', 'Slot $n');

  // ─── Rewards / Profile / Social ───

  // Daily Reward
  static String get claimDailyReward => _s('GÜNLÜK ÖDÜLÜ AL', 'CLAIM TODAY\'S REWARD');
  static String get claimedToday => _s('BUGÜNKÜ ÖDÜL ALINDI! 🎉', 'CLAIMED TODAY! 🎉');
  static String get comeBackTomorrow => _s('YARIN TEKRAR GEL ⏳', 'COME BACK TOMORROW ⏳');
  static String claimedDayReward(int day, int shards) =>
      _s('🎉 $day. Gün Ödülü Alındı (+$shards 🪙)!', '🎉 Claimed Day $day Reward (+$shards 🪙)!');

  // Lucky Wheel
  static String get luckyRunicWheel => _s('MİSTİK ŞANS ÇARKI', 'LUCKY RUNIC WHEEL');
  static String get spinning => _s('ÇEVRİLİYOR...', 'SPINNING...');
  static String get freeSpin => _s('ÜCRETSİZ ÇEVİR!', 'FREE SPIN!');
  static String get extraSpinAd => _s('EKSTRA ÇEVİR (REKLAM)', 'EXTRA SPIN (AD)');
  static String wonPrize(String label) => _s('🎉 KAZANDIN: $label!', '🎉 WON: $label!');

  // Idle Vault
  static String get runicTreasureVault => _s('RÜNİK HAZİNE KASASI', 'RUNIC TREASURE VAULT');
  static String get vaultSubtitle => _s('Siz oyunda yokken Rünik Madenciler sizin için altın biriktirdi!', 'Runic miners gathered gold shards while you were away!');
  static String claimedFromVault(int amount) => _s('🎉 +$amount 🪙 Kasadan Toplandı!', '🎉 +$amount 🪙 Claimed from Vault!');
  static String claimedDoubleFromVault(int amount) => _s('🎉 +$amount 🪙 (2X) Kasadan Toplandı!', '🎉 +$amount 🪙 (2X) Claimed from Vault!');
  static String claim2x(int amount) => _s('2X İLE TOPLA (+$amount 🪙)', '2X CLAIM (+$amount 🪙)');
  static String regularClaim(int amount) => _s('Normal Topla (+$amount 🪙)', 'Regular Claim (+$amount 🪙)');

  // Victory Chest
  static String get tapToOpen => _s('Açmak için dokun!', 'Tap to open!');
  static String get doubleRewardWatchAd => _s('2X KATLA (REKLAM İZLE)', 'DOUBLE REWARD (WATCH AD)');
  static String get claimAndClose => _s('Kapat', 'Claim & Close');

  // Player Profile
  static String get playerProfile => _s('OYUNCU PROFİLİ', 'PLAYER PROFILE');
  static String get titleGrandArchon => _s('Büyük Rün Başbüyücüsü 👑', 'Grand Archon of Runes 👑');
  static String get titleDragonSlayer => _s('Canavar Avcısı ⚔️', 'Monster Slayer ⚔️');
  static String get titleElementalAdept => _s('Element Ustası ⚡', 'Elemental Adept ⚡');
  static String get titleRuneApprentice => _s('Rün Çırağı 📜', 'Rune Apprentice 📜');
  static String get profileBestScore => _s('🏆 Rekor Skor', '🏆 Best Score');
  static String get profileBossesDefeated => _s('👹 Yenilen Boss', '👹 Bosses Defeated');
  static String get profileTotalGold => _s('🪙 Toplam Altın', '🪙 Total Crystals');
  static String get profileTalentPoints => _s('⚡ Yetenek Puanı', '⚡ Talent Points');
  static String get activeBoardSkin => _s('Aktif Tahta Teması:', 'Active Board Skin:');
  static String get runicCodexBestiary => _s('RÜN & CANAVAR KODEKSİ', 'RUNIC CODEX & BESTIARY');

  // Leaderboard
  static String get weeklyLeague => _s('YEREL HAFTALIK LİG', 'LOCAL WEEKLY LEAGUE');
  static String get localLeagueSubtitle =>
      _s('Simüle sıralama · Global yakında', 'Simulated ranking · Global soon');
  static String seasonEndsIn(int days) => _s('⏳ Sezon Sonu: $days Gün', '⏳ Season End: $days Days');
  static String weeklyPrize(int shards) => _s('Haftalık Ödül: +$shards 🪙', 'Weekly Prize: +$shards 🪙');

  // Jukebox
  static String get runicJukebox => _s('RÜNİK MÜZİK KONSOLU', 'RUNIC JUKEBOX');
  static String get proceduralSoundscapes => _s('Prosedürel Ses Manzaraları', 'Procedural Soundscapes');
  static String get lofiDesc => _s('Sakin, analog synth melodileri ve rahatlatıcı baslar.', 'Calm, analog synth melodies and relaxed bass.');
  static String get cyberDesc => _s('Yüksek tempolu elektronik synthler ve fütüristik ritimler.', 'High-tempo electronic synths and futuristic beats.');
  static String get zenDesc => _s('Meditatif çan sesleri, dingin armonikler ve şifa tonları.', 'Meditative bell harmonics and serene ambient tones.');

  // Rune Oracle
  static String get dailyRuneOracle => _s('GÜNLÜK KEHANET KÜRESİ', 'DAILY RUNE ORACLE');
  static String get cosmicTarotDailyBlessing => _s('Kozmik Tarot & Günün Kutsaması', 'Cosmic Tarot & Daily Blessing');
  static String get chooseCardToReveal => _s('✨ Günün Kutsamasını Açmak İçin Bir Kart Seç:', '✨ Choose a Card to Reveal Today’s Blessing:');
  static String nextOracleDrawIn(int hours, int minutes) =>
      _s('Sonraki Kehanet: $hours sa $minutes dk kaldı', 'Next Oracle Draw in: ${hours}h ${minutes}m');

  // Constellations
  static String get astralStarChart => _s('ASTRAL YILDIZ HARİTASI', 'ASTRAL STAR CHART');
  static String get ancientConstellationsStarNodes => _s('Kadim Takımyıldızları & Yıldız Düğümleri', 'Ancient Constellations & Star Nodes');
  static String get activeStar => _s('AÇILDI ✨', 'ACTIVE ✨');

  // Artifact Vault
  static String get artifactVaultTitle => _s('YADİGAR KASASI', 'ARTIFACT VAULT');
  static String get legendarySetsPassiveBuffs => _s('Efsanevi Setler & Pasif Güçler', 'Legendary Sets & Passive Buffs');
  static String get setActive => _s('SET AKTİF ✨', 'SET ACTIVE ✨');
  static String get owned => _s('SAHİPSİN ✓', 'OWNED ✓');

  // Daily Challenge
  static String get dailyChallengeTitle => _s('GÜNLÜK MÜCADELE', 'DAILY CHALLENGE');
  static String get mutator => _s('MODİFİYER', 'MUTATOR');
  static String get bronze => _s('BRONZ', 'BRONZE');
  static String get silver => _s('GÜMÜŞ', 'SILVER');
  static String get gold => _s('ALTIN', 'GOLD');
  static String get diamond => _s('ELMAS', 'DIAMOND');
  static String get startColon => _s('BAŞLA:', 'PLAY');

  // Achievements
  static String get achievementsCodex => _s('BAŞARIMLAR KODEKSİ', 'ACHIEVEMENTS CODEX');

  // Battle Pass
  static String get runicBattlePass => _s('RÜNİK SAVAŞ BİLETİ', 'RUNIC BATTLE PASS');
  static String get seasonOneSubtitle => _s('Sezon 1: Rünik Çağın Doğuşu ⏳ 14 Gün Kaldı', 'Season 1: Dawn of Runes ⏳ 14 Days Left');
  static String tierLevel(int tier) => _s('Seviye $tier / 30', 'Tier $tier / 30');
  static String claimAll(int count) => _s('TÜMÜNÜ AL ($count)', 'CLAIM ALL ($count)');
  static String claimedTierReward(int tier) => _s('🎉 Kademe $tier Ödülü Alındı!', '🎉 Claimed Tier $tier Reward!');
  static String claimedAllSeasonRewards(int shards) => _s('🎉 +$shards 🪙 Tüm Sezon Ödülleri Alındı!', '🎉 +$shards 🪙 All Season Rewards Claimed!');
  static String get vipUnlocked => _s('👑 VIP Savaş Bileti Açıldı!', '👑 VIP Battle Pass Unlocked!');
  static String get unlockVipPass => _s('VIP BİLETİ AÇ', 'UNLOCK VIP PASS');
  static String get freeTrack => _s('ÜCRETSİZ YOL', 'FREE TRACK');
  static String get vipTrack => _s('👑 VIP ALTIN YOL', '👑 VIP TRACK');
  static String get getReward => _s('AL', 'GET');
  // ─── Mystic Systems ───

  // Alchemy dialog.
  static String get runeAlchemyTitle => _s('RÜNİK SİMYA', 'RUNE ALCHEMY');
  static String get runeAlchemySub => _s('Yıldız Tozu Dönüşümü & İksirler', 'Stardust & Tactical Elixirs');
  static String get transmuteRate => _s('100 Altın ➔ 10 Yıldız Tozu', '100 Shards ➔ 10 Stardust');
  static String get mysticChestTitle => _s('✨ MİSTİK SİMYA SANDIĞI ✨', '✨ MYSTIC ALCHEMY CHEST ✨');
  static String get mysticChestLabel => _s('MİSTİK SİMYA SANDIĞI', 'MYSTIC ALCHEMY CHEST');
  static String get mysticChestDesc => _s('Rastgele Altın, XP ve İksirler içerir', 'Contains Random Shards, XP & Elixirs');

  // Enchantment forge dialog.
  static String get enchantmentForgeTitle => _s('EFSUNLAMA OCAĞI', 'ENCHANTMENT FORGE');
  static String get enchantmentForgeDialogSub => _s('Tahta Matris Mühürleri & Büyüler', 'Board Matrix Sigils & Buffs');
  static String get activeSigilSockets => _s('AKTİF EFSUN YUVALARI (3/3)', 'ACTIVE SIGIL SOCKETS (3/3)');
  static String get equipWeapon => _s('KUŞAN ⚔️', 'EQUIP ⚔️');
  static String equipToSlot(String name) => _s('$name Efsununu Hangi Yuvaya Kuşanacaksın?', 'Equip $name to which slot?');

  // Scroll sanctuary dialog.
  static String get arcaneWarScrollsTitle => _s('KADİM PARŞÖMENLER', 'ARCANE WAR SCROLLS');
  static String get arcaneWarScrollsSub => _s('Füzyon Kazanı & Taktiksel Mühürler', 'Fusion Crucible & Tactical Seals');
  static String get noScrollEquipped => _s('Parşömen Kuşanılmadı', 'No Scroll Equipped');
  static String get craftScrollHint => _s('Aşağıdan bir savaş parşömeni üretip kuşanabilirsin.', 'Craft & equip a tactical scroll below to use once in battle.');
  static String get ready => _s('MAÇTA HAZIR', 'READY');
  static String get unequip => _s('Kaldır', 'Unequip');

  // Pet sanctuary dialog.
  static String get familiarsSanctuaryTitle => _s('YOLDAŞLAR KORUNAĞI', 'FAMILIARS SANCTUARY');
  static String get familiarsSanctuarySub => _s('Evcil Hayvanlar & Büyülü Destek', 'Pets & Mystic Companions');
  static String get equippedSparkle => _s('SEÇİLDİ ✨', 'EQUIPPED ✨');
  static String unlockFamiliar(int cost) => _s('🫐 YOLDAŞI AÇ ($cost Yıldız Meyvesi)', '🫐 UNLOCK FAMILIAR ($cost Star Berries)');
  static String feed(int cost) => _s('🫐 BESLE ($cost 🫐)', '🫐 FEED ($cost 🫐)');

  // Title selection dialog.
  static String get hallOfFameTitle => _s('ŞÖHRET VİTRİNİ', 'HALL OF FAME');
  static String get hallOfFameDialogSub => _s('Açılabilir Prestij Unvanları', 'Unlockable Prestige Titles');
  static String get currentTitle => _s('KUŞANILAN UNVAN', 'CURRENT TITLE');
  static String get selected => _s('SEÇİLİ', 'EQUIPPED');

  // Talents dialog.
  static String get talentTreeTitle => _s('YETENEK AĞACI', 'TALENT TREE');
  static String get talentTreeSub => _s('Tüm oyunlar için geçerli kalıcı güçlendirmeler', 'Permanent stat enhancements across all runs');

  // Guild dialog.
  static String get guildTabBoss => _s('⚔️ PATRON', '⚔️ BOSS');
  static String get guildTabMembers => _s('👥 ÜYELER', '👥 MEMBERS');
  static String get guildTabGuilds => _s('🛡️ LONCALAR', '🛡️ GUILDS');
  static String get guildConquestShort => _s('Lonca Bölge Fetihleri (4 Bölge)', 'Guild Territory Conquest Wars');
  static String timeLeft(int days) => _s('⏳ Kalan Süre: $days Gün', '⏳ Time Left: $days Days');
  static String get yourDamage => _s('Katkın', 'Your Dmg');
  static String get milestoneChests => _s('AŞAMA HASAR SANDIKLARI', 'MILESTONE RAID CHESTS');
  static String atHp(int p) => _s('%$p HP Kaldığında', 'At %$p HP');

  // Guild conquest dialog.
  static String get guildConquestTitle => _s('LONCA BÖLGE FETİHLERİ', 'GUILD CONQUEST WARS');
  static String get guildConquestSub => _s('4 Elementel Bölge & Ortak Güçlendirmeler', '4 Elemental Realms & Guild Buffs');
  static String get yourContribution => _s('Kişisel Katkın:', 'Your Contribution:');
  static String get conqueredFlag => _s('🚩 FETHEDİLDİ!', 'CAPTURED!');
  static String get rewardClaimed => _s('Ödül Alındı ✅', 'Reward Claimed ✅');
  static String get joinConquest => _s('FETİH SAVAŞINA KATIL ⚔️', 'JOIN CONQUEST BATTLE ⚔️');
  static String get collectUpper => _s('TOPLA', 'CLAIM');

  // Festival dialog.
  static String get lunarFestivalTitle => _s('AY FESTİVALİ', 'LUNAR FESTIVAL');
  static String get limitedEvent => _s('Sınırlı Süreli Sezonluk Etkinlik', 'Limited-Time Seasonal Event');
  static String eventEndsIn(int days) => _s('Etkinliğin Bitmesine: $days Gün Kaldı', 'Event Ends In: $days Days Left');
  static String get eventQuests => _s('📜 FESTİVAL GÖREVLERİ', '📜 EVENT QUESTS');
  static String get eventBazaar => _s('🏯 FESTİVAL PAZARI', '🏯 EVENT BAZAAR');
  // ─── Content & Adventure ───

  // Codex dialog.
  static String get codexTitle => _s('OYUN VE CANAVAR KODEKSİ', 'GAME & BOSS CODEX');
  static String get codexTabBosses => _s('🐉 Boss', '🐉 Bosses');
  static String get codexTabAlchemy => _s('⚡ Taktikler', '⚡ Tactics');
  static String get codexTabBlessings => _s('🎴 Kutsama', '🎴 Relics');
  static String get codexTabSynergies => _s('🔮 Sinerji', '🔮 Synergies');
  static String get codexBlessingsHeader => _s('🎴 OYUN İÇİ KUTSAMALAR', '🎴 IN-GAME BLESSINGS');
  static String get codexRelicsHeader => _s('🔮 PASİF SİNERJİ YADİGÂRLARI', '🔮 PASSIVE SYNERGY RELICS');
  static String get synergyHeader => _s('🔮 Efsanevi Kalıntı Sinerjileri', '🔮 Legendary Relic Synergies');

  // Codex tactics.
  static String get alchemyMagmaName => _s('Kombo Zinciri (Fever)', 'Combo Chain (Fever)');
  static String get alchemyMagmaDesc => _s('Ardı ardına temizlik yaparak Hyperdrive Fever modunu tetikler, puanları 2 katına çıkarır.', 'Chain consecutive clears to trigger Hyperdrive Fever for a 2X score multiplier.');
  static String get alchemyOverloadName => _s('Çoklu Hat Temizliği', 'Multi-Line Clear');
  static String get alchemyOverloadDesc => _s('Aynı anda 2 veya daha fazla hat temizleyerek devasa bonus puan ve enerji üretir.', 'Clearing 2 or more lines simultaneously awards massive bonus score and energy.');
  static String get alchemyFrostName => _s('Buz Kırıcı Taktik', 'Ice Shatter Tactic');
  static String get alchemyFrostDesc => _s('Dondurulmuş hücreleri çevreleyen hatları temizleyerek buzları kır ve alanı aç.', 'Clear lines adjacent to frozen cells to shatter them and free board space.');
  static String get alchemyVoidName => _s('Mekânsal Alan Yönetimi', 'Spatial Grid Control');
  static String get alchemyVoidDesc => _s('Büyük taşlar için daima köşelerde ve merkezde 3x3 açık alanlar bırak.', 'Keep open 3x3 pockets in corners and center to accommodate large shapes.');
  static String get alchemyMidasName => _s('Midas Bereketi', 'Midas Wealth');
  static String get alchemyMidasDesc => _s('Her temizlikte oyuncu cüzdanına ekstra Altın Şarapnel kazandırır.', 'Grants bonus Gold Shards directly to your vault with every line clear.');

  // Codex relic synergies.
  static String get synergyElementalTitle => _s('🔥⚡ Kombo Zinciri', '🔥⚡ Combo Chain');
  static String get synergyElementalCombo => _s('Hızlı Yerleşim + Çoklu Temizlik', 'Fast Placement + Multi-Clear');
  static String get synergyElementalDesc => _s('Seri temizliklerde kombo çarpanı katlanarak artar ve devasa skor patlaması yaratır.', 'Consecutive clears stack combo multipliers exponentially for massive high scores.');
  static String get synergyMidasTitle => _s('👑🪙 Midas Hükümdarlığı', '👑🪙 Midas Dominion');
  static String get synergyMidasCombo => _s('Altın Dokunuşu + Midas Bereketi', 'Gold Touch + Midas Wealth');
  static String get synergyMidasDesc => _s('Tüm satır/sütun temizliklerinde kazanılan Altın Şarapnel miktarı kalıcı olarak +%50 artar.', 'Permanently increases all Gold Shard rewards from line clears by +50%.');
  static String get synergyGuardianTitle => _s('🛡️⏳ Ölümsüz Muhafız', '🛡️⏳ Immortal Guardian');
  static String get synergyGuardianCombo => _s('Acil Durum Çekirdeği + Anka Tüyü', 'Emergency Core + Phoenix Feather');
  static String get synergyGuardianDesc => _s('Hamle kalmadığında devreye giren acil durum kurtarma sistemi tahtayı temizleyerek oyunu kurtarır.', 'Emergency safety system clears critical grid areas upon fatal moves.');

  // Bestiary dialog.
  static String get elementalWeakness => _s('Elementel Zayıflık: ', 'Elemental Weakness: ');
  static String get loreOrigin => _s('HİKAYE & KÖKEN', 'LORE & ORIGIN');
  static String get battleStrategy => _s('SAVAŞ TAKTİĞİ', 'BATTLE STRATEGY');
  static String get bestiaryTitle => _s('RÜNİK KODEKS', 'RUNIC BESTIARY');
  static String get bestiarySubtitle => _s('Elementel Canavar & Boss Ansiklopedisi', 'Elemental Monster & Boss Encyclopedia');
  static String get unknownMonster => _s('Bilinmeyen Canavar', 'Unknown Monster');
  static String get loreButton => _s('İNCELE', 'LORE');
  static String discoveryProgress(int discovered) => _s('Keşif İlerlemesi: $discovered/10', 'Discovery: $discovered/10');

  static String get selectedCheck => _s('SEÇİLDİ ✓', 'ACTIVE ✓');

  // Dragon system.
  static String get dragonTitle => _s('EJDERHA SİSTEMİ', 'DRAGON SYSTEM');
  static String get dragonSubtitle => _s('Ejderha Yumurtası Seç & Güçlendir', 'Choose & Empower Your Dragon');
  static String get chooseFirstDragon => _s('EJDERHA YUMURTASI SEÇ', 'CHOOSE YOUR DRAGON EGG');
  static String get chooseYourDragon => _s('EJDERHA YUMURTANI SEÇ', 'CHOOSE YOUR DRAGON');
  static String get changeDragon => _s('EJDERHA DEĞİŞTİR', 'CHANGE DRAGON');
  static String get dragonSelectionSubtitle => _s('Yumurtanı seç, ejderhanı büyüt.', 'Choose your egg, grow your dragon.');
  static String get confirmEgg => _s('YUMURTAYI ONAYLA', 'CONFIRM EGG');
  static String get dragonLevel => _s('Seviye', 'Level');
  static String get dragonExpLabel => _s('EXP', 'EXP');
  static String dragonSelected(String name) => _s('🐉 $name Aktif Ejderha Olarak Seçildi!', '🐉 Selected $name as Active Dragon!');
  static String dragonChosen(String name) => _s('🥚 $name yumurtası seçildi!', '🥚 Chose $name egg!');
  static String get dragonEvolved => _s('EJDERHA EVRİLDİ!', 'DRAGON EVOLVED!');
  static String dragonEvolvedTo(String stage) => _s('🐉 Ejderhan $stage formuna evrildi!', '🐉 Your dragon evolved to $stage!');
  static String unlockEggCost(int cost) => _s('🥚 $cost 🪙 ile kilidi aç', '🥚 Unlock for $cost 🪙');
  static String dragonPowerReady(String powerName) => _s('$powerName HAZIR!', '$powerName READY!');
  static String get dragonPassiveBonus => _s('Pasif Bonus', 'Passive Bonus');
  static String dragonExpGain(int exp) => _s('+$exp EXP', '+$exp EXP');

  // Spire map dialog.
  static String get spireTitle => _s('RÜNİK KULE', 'RUNIC SPIRE');
  static String get spireSubtitle => _s('10 Katlı Taktiksel Meydan Okuma', '10-Floor Tactical Trial Tower');
  static String get clearedCheck => _s('TAMAM ✓', 'CLEARED ✓');
  static String get unlockByPreviousFloor => _s('Önceki katı tamamlayarak kilidi aç', 'Unlock by beating previous floor');

  // Puzzle screens.
  static String get puzzleCompleted => _s('BULMACA TAMAMLANDI!', 'PUZZLE COMPLETED!');
  static String get outOfMoves => _s('HAMLELER TÜKENDİ!', 'OUT OF MOVES!');
  static String get targetLinesNotCleared => _s('Hedef hatları temizleyemedin. Tekrar denemek ister misin?', 'Target lines were not cleared. Retry?');
  static String get puzzleMasterTitle => _s('BULMACA USTASI', 'PUZZLE MASTER');
  static String get puzzleMapSubtitle => _s('30 Taktiksel Zihin Egzersizi', '30 Hand-crafted Brain Teasers');
  static String get chapterApprentice => _s('1. Çırak', '1. Apprentice');
  static String get chapterMaster => _s('2. Usta', '2. Master');
  static String get chapterArchitect => _s('3. Mimar', '3. Architect');

  // Adventure map & screen.
  static String get dungeonTitle => _s('SONSUZ ZİNDAN', 'INFINITE DUNGEON');
  static String get enterBattle => _s('SAVAŞA GİR ⚔️', 'ENTER ⚔️');
  static String deepestFloor(int i) => _s('EN DERİN KAT: Kat $i', 'DEEPEST FLOOR: Floor $i');
  static String shardsEarned(int reward) => _s('+$reward Altın Kazanıldı!', '+$reward Shards Earned!');
  static String nextFloor(int level) => _s('SONRAKİ KAT ($level) ➔', 'NEXT FLOOR ($level) ➔');
  static String get returnToDungeonMap => _s('ZİNDAN HARİTASINA DÖN', 'RETURN TO MAP');
  static String get retryAgain => _s('TEKRAR DENE 🔄', 'TRY AGAIN 🔄');

  // Expeditions dialog.
  static String get expeditionsTitle => _s('KEŞİF SEFERLERİ', 'EXPEDITIONS');
  static String get expeditionsSubtitle => _s('Zamanlı Ejderha Görevleri', 'Timed Dragon Expeditions');
  static String get allDragonsBusy => _s('❌ Tüm ejderhalar şu anda görevde!', '❌ All dragons are currently on expeditions!');
  static String get selectDragon => _s('Ejderhını Seç', 'Select Your Dragon');
  static String get startExpedition => _s('GÖNDER', 'START');
  static String get dragonReturned => _s('döndü!', 'returned!');
  static String get dragonExploring => _s('görevde', 'exploring');
  static String expeditionCompleted(int shards, int stardust, int xp) => _s('🎉 Keşif Tamamlandı: +$shards Altın, +$stardust Yıldız Tozu, +$xp XP!', '🎉 Expedition Completed: +$shards Shards, +$stardust Stardust, +$xp XP!');

  // Tournament arena dialog.
  static String get heroName => _s('Kahraman', 'Hero');
  static String get tournamentTitle => _s('ELEMENTEL TURNUVA', 'GLORY TOURNAMENT');
  static String get leaderboardTab => _s('🏆 Sıralama Grubu', '🏆 Live Bracket');
  static String get tierRewardsTab => _s('🎁 Sezon Ödülleri', '🎁 Tier Rewards');
  static String get startTournamentBattle => _s('TURNUVA MAÇINA BAŞLA ⚡', 'START TOURNAMENT BATTLE ⚡');
  static String get claimButton => _s('TOPLA', 'CLAIM');

  // Particle FX lab dialog.
  static String get particleLabTitle => _s('PARÇACIK LABORATUVARI', 'PARTICLE FX LAB');
  static String get particleLabSubtitle => _s('Özel Sürükleme İzi & Patlama Atölyesi', 'Custom Trails & Fireworks Atelier');
  static String get particleLabHint => _s('✨ Tuvalde parmağını gezdir veya dokun', '✨ Drag or tap to test active VFX');
  static String get equippedActive => _s('KUŞANILDI', 'ACTIVE');
  static String trailsTab(int n) => _s('✨ Sürükleme İzi ($n)', '✨ Trails ($n)');
  static String fireworksTab(int n) => _s('🎆 Satır Patlaması ($n)', '🎆 Fireworks ($n)');

  // Tutorial dialog.
  static String get tutorialSlide1Title => _s('1. Blokları Yerleştir & Çizgileri Temizle', '1. Place Blocks & Clear Lines');
  static String get tutorialSlide1Desc => _s('Alt paneldeki blokları 8x8 tahtaya sürükle. Tam dolu yatay ve dikey çizgiler patlayarak sana puan ve enerji kazandırır!', 'Drag polyomino pieces onto the 8x8 board. Complete horizontal or vertical lines to vaporize them for score and energy!');
  static String get tutorialSlide1Badge => _s('TEMEL MEKANİK', 'BASIC MECHANIC');
  static String get tutorialSlide2Title => _s('2. Kombo Serileri & Çılgınlık', '2. Combo Streaks & Fever');
  static String get tutorialSlide2Desc => _s('Arka arkaya hatları temizleyerek kombo serisi yakala! Çoklu temizlikler ve seri hamleler skorunu katlar.', 'Clear lines in rapid succession to build combos! Multi-line clears and streaks multiply your score.');
  static String get tutorialSlide2Badge => _s('KOMBO SİSTEMİ', 'COMBO SYSTEM');
  static String get tutorialSlide3Title => _s('3. Hyperdrive Fever (Çılgınlık) Modu', '3. Hyperdrive Fever Frenzy');
  static String get tutorialSlide3Desc => _s('Kombo serileri yaptıkça Hyperdrive sayacın dolar. %100 olduğunda 3 hamle boyunca TÜM puanlar 2 KATINA çıkar ve altın yağar!', 'Line clears and combos charge your Hyperdrive gauge. At 100%, enter Fever for 3 moves with 2X multiplier and gold bursts!');
  static String get tutorialSlide3Badge => _s('2X ÇILGINLIK', '2X FEVER MULTIPLIER');
  static String get tutorialSlide4Title => _s('4. Boss Seferi & Mistik Kutsamalar', '4. Boss Campaign & Blessings');
  static String get tutorialSlide4Desc => _s('16 aşamalı Boss Seferinde 4 devasa yaratıkla savaş! Skor eşiklerini aşarak her oyunda değişen Roguelike rün kartlarını kuşan!', 'Battle 4 titanic realm bosses across 16 stages! Surpass score milestones to draft game-changing roguelike blessing cards!');
  static String get tutorialSlide4Badge => _s('EPİK MACERA', 'EPIC CAMPAIGN');
  static String get tutorialSlide5Title => _s('5. Ejderhalar, Loncalar & Simya', '5. Dragons, Guilds & Alchemy');
  static String get tutorialSlide5Desc => _s('Ejderhanın güçlerini (Alev Nefesi, Donmuş Koruma vb.) canlı savaşta kullan, Loncanla Dünya Patronuna hasar ver ve Simya ile taktiksel iksirler üret!', 'Unleash Dragon powers (Fire Breath, Frozen Protection), raid World Boss with your Guild, and craft tactical match elixirs with Alchemy!');
  static String get tutorialSlide5Badge => _s('İLERİ SEVİYE USTALIK', 'ADVANCED MASTERY');
  static String get letsPlay => _s('OYNA VE KEŞFET! 🚀', 'LET\'S PLAY! 🚀');

  // Shop screen.
  static String get claimedFreeShards => _s('🎉 +100 Ücretsiz Altın Eklendi!', '🎉 Claimed +100 Free Shards!');
  static String get adUnavailable => _s('Reklam yüklenemedi, tekrar dene.', 'Ad unavailable, try again.');
  static String get notEnoughGoldShards => _s('❌ Yetersiz Altın Parçacığı!', '❌ Not enough Gold Shards!');
  static String get lineClearFxHeader => _s('HAT TEMİZLEME EFEKTLERİ', 'LINE CLEAR FX STYLES');
  static String get equipTheme => _s('TEMAYI KUŞAN', 'EQUIP THEME');
  static String unlockedSkin(String name) => _s('🎉 $name Kilidi Açıldı!', '🎉 Unlocked $name!');
  static String unlockedFx(String name) => _s('🎉 $name Efekti Kilidi Açıldı!', '🎉 Unlocked $name!');
  static String unlockPrice(int p) => _s('KİLİDİ AÇ (🪙 $p)', 'UNLOCK (🪙 $p)');

  // ─── Shop Market UI ───────────────────────────────────────────────────────
  static String get ancientMagicShop => _s('KADİM BÜYÜ MAĞAZASI', 'ANCIENT MAGIC SHOP');
  static String get shopTabThemes => _s('Temalar', 'Themes');
  static String get shopTabVfx => _s('VFX', 'VFX');
  static String get shopTabBundles => _s('Paketler', 'Bundles');
  static String get shopTabFree => _s('Ücretsiz', 'Free');
  static String get shopBlockColorThemes => _s('BLOK & RENK TEMALARI', 'BLOCK & COLOR THEMES');
  static String get shopPaletteMixerCta => _s('PALET MİKSERİ ➔', 'PALETTE MIXER ➔');
  static String get shopAncientBoards => _s('KADİM TAHTA MATRİSLERİ', 'ANCIENT BOARD MATRICES');
  static String get shopLiveVfxHeader => _s('CANLI PATLATMA & VFX KOZMETİKLERİ', 'LIVE CLEAR & VFX COSMETICS');
  static String get shopGoldVipHeader => _s('ALTIN & VIP AVANTAJ PAKETLERİ', 'GOLD & VIP BUNDLES');
  static String get shopTagPopular => _s('EN POPÜLER', 'MOST POPULAR');
  static String get shopTagValue => _s('3X DEĞER', '3X VALUE');
  static String get shopTagLifetime => _s('ÖMÜR BOYU', 'LIFETIME');
  static String get shopOwned => _s('SAHİPSİN', 'OWNED');
  static String get shopPaymentTitle => _s('ÖDEME', 'PAYMENT');
  static String get shopPaymentOpened =>
      _s('Google Play ödeme ekranı açıldı. Onay sonrası teslim edilir.',
          'Google Play checkout opened. Delivery after confirmation.');
  static String get shopPurchaseFailed => _s('Satın alma başlatılamadı.', 'Could not start purchase.');
  static String get shopRestorePurchases => _s('Satın Alımları Geri Yükle', 'Restore Purchases');
  static String get shopRestoreDone => _s('Satın alımlar geri yüklendi.', 'Purchases restored.');
  static String get shopRestoreTitle => _s('GERİ YÜKLEME', 'RESTORE');
  static String get shopFreeDailyGold => _s('ÜCRETSİZ GÜNLÜK ALTIN', 'FREE DAILY GOLD');
  static String get shopFreeDailyGoldDesc =>
      _s('Kısa bir video izle ve anında +100 Altın kazan!',
          'Watch a short video and earn +100 Gold instantly!');
  static String get shopWatchAd => _s('İZLE', 'WATCH');
  static String get shopDailyRewardTitle => _s('GÜNLÜK ÖDÜL', 'DAILY REWARD');
  static String shopGainedGold(int n) => _s('+$n Altın Kazandın!', '+$n Gold earned!');
  static String get shopAdNotReady =>
      _s('Reklam hazır değil, lütfen tekrar dene.', 'Ad not ready, please try again.');
  static String get shopWizardGrace => _s('BÜYÜCÜ LÜTFU', 'WIZARD\'S GRACE');
  static String get shopWizardGraceDesc =>
      _s('Günün ücretsiz ikramiyesi: +50 Altın Şarapnel',
          'Today\'s free bonus: +50 Gold Shards');
  static String get shopCollect => _s('TOPLA', 'COLLECT');
  static String shopWizardGraceClaimed(int n) =>
      _s('+$n Altın Lütfu Alındı!', '+$n Grace Gold claimed!');
  static String get shopThemeActiveTitle => _s('TEMA AKTİF', 'THEME ACTIVE');
  static String themeEquippedMsg(String name) => _s('$name kuşanıldı!', '$name equipped!');
  static String get shopThemeUnlockedTitle => _s('TEMA AÇILDI', 'THEME UNLOCKED');
  static String themeUnlockedMsg(String name) => _s('$name açıldı!', '$name unlocked!');
  static String themeUnlockedAndEquipped(String name) =>
      _s('$name teması açıldı ve kuşanıldı!', '$name unlocked and equipped!');
  static String get shopVfxUnlockedTitle => _s('VFX AÇILDI', 'VFX UNLOCKED');
  static String fxUnlockedMsg(String name) => _s('$name efekti açıldı!', '$name effect unlocked!');
  static String get shopBalanceLowTitle => _s('BAKİYE YETERSİZ', 'LOW BALANCE');
  static String get shopNotEnoughGold => _s('Yeterli altın yok!', 'Not enough gold!');
  static String get shopEquippedCheck => _s('✓ KUŞANILDI', '✓ EQUIPPED');
  static String get shopBuyLabel => _s('SATIN AL', 'BUY');
  static String get shopHeroDealTitle => _s('KADİM BÜYÜCÜ PAKETİ', 'ANCIENT WIZARD PACK');
  static String get shopHeroDealSubtitle =>
      _s('1.500 Altın Şarapnel — sınırlı süre', '1,500 Gold Shards — limited time');
  static String buyForShards(int price) => _s('SATIN AL (🪙 $price)', 'BUY (🪙 $price)');

  // ─── In-Game UI & Floating Text ───────────────────────────────────────────
  static String blitzTimer(int seconds) {
    final s = seconds.toString().padLeft(2, '0');
    return _s('BLITZ: ${s}s (+3s / Satır)', 'BLITZ: ${s}s (+3s / Line)');
  }

  static String get zenModeBanner => _s('ZEN MODU • RAHAT VE SONSUZ', 'ZEN MODE • RELAX & ENDLESS');
  static String bossStage(int stage) => _s('KADEME $stage/5', 'TIER $stage/5');
  static String get specialReward => _s('Özel Ödül', 'Special Reward');
  static String openCost(int cost) => _s('AÇ ($cost 🪙)', 'OPEN ($cost 🪙)');
  static String get craftLabel => _s('ÜRET: ', 'CRAFT: ');
  static String craftElixir(int cost) => _s('ÜRET ($cost ✨)', 'CRAFT ($cost ✨)');
  static String openMysticChestCost(int cost) => _s('AÇ ($cost ✨)', 'OPEN ($cost ✨)');
  static String levelLabel(int level) => _s('Seviye $level', 'Level $level');
  static String floorRange(int start, int end) => _s('Kat $start - $end', 'Floors $start - $end');
  static String get claimedMark => _s('ALINDI ✅', 'CLAIMED ✅');
  static String bossDefeated(String name) => _s('👑 ${name.toUpperCase()} MAĞLUP EDİLDİ!', '👑 ${name.toUpperCase()} DEFEATED!');
  static String get bossVictorySubtitle => _s('Efsanevi Boss Zaferi! Rünik Zafer Sandığını Aç!', 'Legendary Boss Victory! Open the Runic Victory Chest!');
  static String levelCompleted(String title) => _s('$title Başarıyla Tamamlandı!', '$title Completed!');
  static String needEnergyAmount(int cost) => _s('$cost Enerji Lazım!', 'Need $cost Energy!');

  // ─── Duel & Misc ──────────────────────────────────────────────────────────
  static String get duelVictory => _s('⚔️ DÜELLO ZAFERİ!', '⚔️ DUEL VICTORY!');
  static String get duelDefeat => _s('💀 DÜELLO YENİLGİSİ', '💀 DUEL DEFEAT');
  static String wonAgainst(String name) => _s('$name karşısında muazzam bir zafer kazandın!', 'A magnificent victory over $name!');
  static String lostTo(String name) => _s('$name bu düelloyu önde tamamladı.', '$name finished this duel ahead.');
  static String get you => _s('👤 SİZ', '👤 YOU');
  static String leagueTrophies(String delta) => _s('$delta Lig Kupası', '$delta League Trophies');
  static String totalTrophies(int trophies, String league) => _s('Toplam Kupa: $trophies ($league)', 'Total Trophies: $trophies ($league)');
  static String shardXp(int shards) => _s('+$shards Altın  |  +80 XP', '+$shards Gold  |  +80 XP');
  static String get startNewDuel => _s('YENİ DÜELLO BAŞLAT ⚔️', 'START NEW DUEL ⚔️');
  static String get backToMainMenu => _s('ANA MENÜYE DÖN', 'BACK TO MAIN MENU');
  static String mysticChestShards(int n) => _s('🪙 +$n Altın Şarapnel', '🪙 +$n Gold Shards');
  static String mysticChestXp(int n) => _s('⚡ +$n Savaş Bileti XP', '⚡ +$n Battle Pass XP');
  static String itemCount(int qty) => _s('($qty adet)', '($qty pcs)');
  static String get awesome => _s('HARİKA!', 'AWESOME!');
  static String weaknessLabel(String weakness) => _s('Zayıflık: $weakness', 'Weakness: $weakness');
  static String get encounterToDiscover => _s('Keşfetmek için zindanda karşılaş', 'Encounter in the dungeon to discover');

  // ─── Adventure / Boss Campaign ────────────────────────────────────────────
  static String get movesRanOut => _s('Hamleler tükendi!', 'Out of moves!');
  static String get boardFull => _s('Tahtada yer kalmadı!', 'No space left on the board!');
  static String get counterAttack => _s('⚔️ Karşı Saldırı:', '⚔️ Counter Attack:');
  static String placementsUntilAttack(int n) => _s('$n Blok Yerleşimi', '$n Block Placements');
  static String get frozenBlocksLeft => _s('🧊 Kalan Donmuş Blok:', '🧊 Frozen Blocks Left:');
  static String get runesCollected => _s('✨ Toplanan Rünler:', '✨ Runes Collected:');
  static String get targetScore => _s('🎯 Hedef Puan:', '🎯 Target Score:');
  static String get depthRankEternal => _s('👑 Ebedi Rün Lordu', '👑 Eternal Rune Lord');
  static String get depthRankAbyss => _s('🔮 Uçurum Fatihi', '🔮 Abyss Conqueror');
  static String get depthRankGold => _s('⚔️ Altın Şövalye', '⚔️ Golden Knight');
  static String get depthRankIron => _s('🛡️ Demir Muhafız', '🛡️ Iron Guardian');
  static String get depthRankRookie => _s('🍃 Çaylak Gezgin', '🍃 Rookie Wanderer');

  // ─── In-Game Floating Text & Blessings ────────────────────────────────────
  static String get blessingSelectionTitle => _s('MİSTİK GÜÇ SEÇİMİ', 'MYSTIC POWER SELECTION');
  static String get blessingSelectionSubtitle => _s('Skor eşiğini aştın! Bu maç için bir rün kutsaması seç:', 'You crossed the score threshold! Choose a rune blessing for this match:');
  static String get timeStopped => _s('⏳ ZAMAN DURDURULDU! (+15s)', '⏳ TIME FROZEN! (+15s)');
  static String get midasTouch => _s('💰 MİDAS DOKUNUŞU! +350 🪙', '💰 MIDAS TOUCH! +350 🪙');
  static String get holyPurification => _s('🕊️ KUTSAL ARINMA GERÇEKLEŞTİ!', '🕊️ HOLY PURIFICATION!');
  static String get newRecordVictory => _s('🏆 YENİ REKOR ZAFERİ!', '🏆 NEW RECORD VICTORY!');
  static String get newRecordSubtitle => _s('Yeni Zirveye Ulaştın! Rekor Zafer Sandığını Aç!', 'You reached a new peak! Open the Record Victory Chest!');
  static String get ultimateReady => _s('⚡ AKTİF!', '⚡ READY!');
  static String dayStreak(int day) => _s('$day. Gün', 'Day $day');
}
