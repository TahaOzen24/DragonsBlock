# Rol ve Bağlam
Sen kıdemli bir Mobil Oyun Geliştiricisi, UI/UX Tasarımcısı ve Flutter/Flame Engine Uzmanısın. Şu anda Flutter ve Flame Engine kullanarak geliştirdiğim "Block Blast" mekaniklerine sahip mobil bulmaca oyunumun görsel, işitsel ve akıcılık (performance & juice) kalitesini tamamen yenilemek ve endüstri standardı profesyonel bir seviyeye getirmek istiyorum. 

Mevcut tasarımdan hiç memnun değilim. Özellikle blok akıcılığı, patlama efektleri, renk uyumu, blok görselleri/materyalleri ve arka plan atmosferi konusunda sıfırdan ve kusursuz bir mimari istiyorum.

# İstenen Geliştirmeler ve Detaylı Planlama Başlıkları

Lütfen aşağıdaki 5 ana başlık altında profesyonel, uygulanabilir ve kod odaklı detaylı bir planlama ve uygulama rehberi hazırla:

## 1. Akıcılık ve Dokunma Deneyimi (Juice & Responsiveness)
- Sürükle-bırak (Drag & Drop) mekaniğinin parmakla %100 senkronize olması ve gecikmesiz (lag-free) çalışması için optimizasyon.
- Bloklar ızgaraya (grid) oturduğunda veya geçersiz bir yere bırakıldığında tatmin edici yaylanma (spring/bounce) ve "snapping" animasyonları.
- Kullanıcıya dokunma geri bildirimi (haptic feedback) entegrasyonu için en iyi pratikler.

## 2. Parçacık ve Patlama Efektleri (VFX & Particle Systems)
- Blok patlatma (satır/sütun patlaması) anında ekranı doldurmayan ama son derece şık ve modern duran parçacık (particle) efektleri.
- Parlama (glow), ekran sarsıntısı (screen shake - hafif ve kontrollü), renk patlamaları ve "juicy" geri bildirimler için Flame ParticleSystemComponent veya özel shader kullanımları.
- Zincirleme reaksiyonlarda (combo) görsel yoğunluğun artması için dinamik efekt kademelendirmesi.

## 3. Renk Paleti ve Blok Estetiği (Color Theory & Materials)
- Klasik renkler yerine modern mobil oyunlarda (örn. koyu mod ağırlıklı, neon veya pastel modern tonlar) kullanılan, göz yormayan, kontrastı yüksek bir renk paleti.
- Blokların düz renk olmaktan çıkarılıp hafif gradyanlar, iç gölgeler (inner shadow), cam efekti (glassmorphism) veya modern 2.5D/flat tasarım detaylarıyla zenginleştirilmesi.
- Farklı şekillerdeki blokların (tetrominolar vb.) birbirleriyle görsel uyumu.

## 4. Arka Plan ve Atmosfer Tasarımı (Environment & Lighting)
- Blokların arkasındaki ana oyun alanının (board) ve genel arayüz arka planının oyunun odak noktasını (blokları) dağıtmayacak şekilde tasarlanması.
- Derinlik algısı yaratan hafif gradientler, minimalist arkaplan desenleri veya atmosferik ışıklandırma efektleri.
- Renklerin oyun akışına göre dinamik olarak hafifçe değişebileceği (örneğin skor arttıkça veya kombo yapıldıkça) atmosferik bir yapı.

## 5. Flutter & Flame Teknik Uygulama Mimarisi
- Bu geliştirmelerin performans kaybına (FPS düşüşü) yol açmaması için Flame tarafında SpriteBatch, optimizasyon teknikleri ve render katmanı yönetimi.
- Kod mimarisinin modüler ve temiz tutulması için önerilen state ve component yapıları.

# Beklenen Çıktı Formatı
Lütfen bana karmaşık teoriler anlatmak yerine; doğrudan projeme uygulayabileceğim **adım adım bir aksiyon planı**, kullanılacak renk kodları (HEX), animasyon eğrileri (Curves) ve kritik noktalarda örnek Flame/Dart kod bloklarını içeren kapsamlı bir rehber sun.