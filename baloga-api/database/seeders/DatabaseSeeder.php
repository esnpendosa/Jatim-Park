<?php

namespace Database\Seeders;

use App\Models\AppSetting;
use App\Models\Badge;
use App\Models\Item;
use App\Models\Mission;
use App\Models\SpawnPoint;
use App\Models\Species;
use App\Models\User;
use App\Models\UserItem;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $balogaLat = -7.892543;
        $balogaLng = 112.548972;

        // 2. Seed Species (Including Rozitech Dataset & Iconic Baloga Flora/Fauna)
        $speciesData = [
            [
                'name' => 'Harimau Sumatra',
                'latin_name' => 'Panthera tigris sumatrae',
                'category' => 'hewan',
                'rarity' => 'legendary',
                'habitat' => 'Hutan Hujan Sumatra',
                'food' => 'Karnivora (Rusa, Babi Hutan)',
                'ecological_role' => 'Predator puncak pengendali ekosistem hutan',
                'conservation_status' => 'Kritis (Critically Endangered)',
                'fun_fact' => 'Harimau Sumatra adalah subspesies harimau terkecil yang masih ada di dunia.',
                'base_cp' => 1500,
                'thumbnail_url' => 'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?w=500',
            ],
            [
                'name' => 'Honda PCX 160',
                'latin_name' => 'Motorcycle PCX 160cc',
                'category' => 'hewan',
                'rarity' => 'epic',
                'habitat' => 'Kawasan Rozitech Office',
                'food' => 'Pertamax Turbo',
                'ecological_role' => 'Kendaraan operasional utama Ranger Rozitech',
                'conservation_status' => 'Aktif Beroperasi',
                'fun_fact' => 'Kendaraan matic premium yang menjadi armada utama survey lokasi.',
                'base_cp' => 1250,
                'thumbnail_url' => 'assets/Honda PCX 160.jpg',
            ],
            [
                'name' => 'Pohon Pisang',
                'latin_name' => 'Musa paradisiaca',
                'category' => 'tumbuhan',
                'rarity' => 'common',
                'habitat' => 'Area Perkebunan Rozitech',
                'food' => 'Fotosintesis',
                'ecological_role' => 'Penyedia pangan dan penahan erosi tanah',
                'conservation_status' => 'Melimpah (Least Concern)',
                'fun_fact' => 'Tumbuhan terna raksasa yang daun dan buahnya bermanfaat bagi ekosistem.',
                'base_cp' => 450,
                'thumbnail_url' => 'assets/Pohon Pisang.jpg',
            ],
            [
                'name' => 'Lidah Mertua',
                'latin_name' => 'Sansevieria trifasciata',
                'category' => 'tumbuhan',
                'rarity' => 'rare',
                'habitat' => 'Taman Edelweis Rozitech',
                'food' => 'Fotosintesis',
                'ecological_role' => 'Pembersih dan pemurni polusi udara',
                'conservation_status' => 'Dilindungi (Protected)',
                'fun_fact' => 'Tanaman hias penghasil oksigen tinggi dan penyerap zat beracun.',
                'base_cp' => 750,
                'thumbnail_url' => 'assets/Lidah Mertua.jpg',
            ],
            [
                'name' => 'Rumput Ekor Kucing',
                'latin_name' => 'Typha latifolia',
                'category' => 'tumbuhan',
                'rarity' => 'common',
                'habitat' => 'Lahan Lembab Rozitech',
                'food' => 'Fotosintesis',
                'ecological_role' => 'Penjaga kelembaban tanah dan mikroba',
                'conservation_status' => 'Aman',
                'fun_fact' => 'Tumbuhan unik berbentuk seperti ekor kucing yang tumbuh di area lembab.',
                'base_cp' => 350,
                'thumbnail_url' => 'assets/Rumput Ekor Kucing.jpg',
            ],
            [
                'name' => 'Bayam Duri',
                'latin_name' => 'Amaranthus spinosus',
                'category' => 'tumbuhan',
                'rarity' => 'common',
                'habitat' => 'Area Kebun Belakang',
                'food' => 'Fotosintesis',
                'ecological_role' => 'Tumbuhan obat alami ekosistem',
                'conservation_status' => 'Melimpah',
                'fun_fact' => 'Tumbuhan obat tradisional dengan batang berduri khas.',
                'base_cp' => 300,
                'thumbnail_url' => 'assets/Bayam Duri.jpg',
            ],
            [
                'name' => 'Sandal Selop Karet Pria',
                'latin_name' => 'Footwear Rubber Craft',
                'category' => 'hewan',
                'rarity' => 'rare',
                'habitat' => 'Markas Ranger Rozitech',
                'food' => 'Karet Alam',
                'ecological_role' => 'Perlengkapan wajib jalan kaki Ranger',
                'conservation_status' => 'Siap Pakai',
                'fun_fact' => 'Perlengkapan kaki tahan air buatan lokal untuk patroli lapangan.',
                'base_cp' => 650,
                'thumbnail_url' => 'assets/Sandal Selop Karet Pria.jpg',
            ],
            [
                'name' => 'Saga Rambat',
                'latin_name' => 'Abrus precatorius',
                'category' => 'tumbuhan',
                'rarity' => 'epic',
                'habitat' => 'Pagar Halaman Rozitech',
                'food' => 'Fotosintesis',
                'ecological_role' => 'Penutup tanah dan peneduh alami',
                'conservation_status' => 'Langka (Rare)',
                'fun_fact' => 'Tumbuhan merambat dengan biji merah cantik yang khas.',
                'base_cp' => 950,
                'thumbnail_url' => 'assets/Saga Rambat.jpg',
            ],
            [
                'name' => 'Kudzu',
                'latin_name' => 'Pueraria montana',
                'category' => 'tumbuhan',
                'rarity' => 'rare',
                'habitat' => 'Area Perbukitan',
                'food' => 'Fotosintesis',
                'ecological_role' => 'Penyerap nitrogen tanah',
                'conservation_status' => 'Terjaga',
                'fun_fact' => 'Tanaman polong-polongan merambat dengan daya tumbuh cepat.',
                'base_cp' => 850,
                'thumbnail_url' => 'assets/Kudzu.jpg',
            ],
            [
                'name' => 'Daun Mangga',
                'latin_name' => 'Mangifera indica',
                'category' => 'tumbuhan',
                'rarity' => 'common',
                'habitat' => 'Halaman Depan Rozitech',
                'food' => 'Fotosintesis',
                'ecological_role' => 'Peneduh dan produsen oksigen',
                'conservation_status' => 'Aman',
                'fun_fact' => 'Daun pohon mangga kaya antioksidan alami.',
                'base_cp' => 400,
                'thumbnail_url' => 'assets/daun mangga.jpg',
            ],
        ];

        foreach ($speciesData as $data) {
            $s = Species::updateOrCreate(['name' => $data['name']], $data);

            // Seed Spawn Points nearby Baloga
            SpawnPoint::firstOrCreate(
                [
                    'species_id' => $s->id,
                    'latitude' => $balogaLat + (rand(-100, 100) / 10000.0),
                    'longitude' => $balogaLng + (rand(-100, 100) / 10000.0),
                ],
                [
                    'active' => true,
                    'respawn_minutes' => 15,
                ]
            );
        }

        // 3. Seed Items / Eko-Spheres
        $items = [
            [
                'name' => 'Eko-Sphere Regular',
                'description' => 'Bola penangkap spesies standar buatan Baloga Tech',
                'type' => 'capture_ball',
                'icon_url' => 'assets/items/ekosphere_regular.png',
            ],
            [
                'name' => 'Eko-Sphere Great',
                'description' => 'Bola penangkap dengan tingkat keberhasilan +20% lebih tinggi',
                'type' => 'capture_ball',
                'icon_url' => 'assets/items/ekosphere_great.png',
            ],
            [
                'name' => 'Radar Ekologi',
                'description' => 'Alat peningkat jangkauan deteksi spesies langka di sekitar Baloga',
                'type' => 'radar',
                'icon_url' => 'assets/items/radar_eco.png',
            ],
        ];

        foreach ($items as $itemData) {
            Item::firstOrCreate(['name' => $itemData['name']], $itemData);
        }

        // 4. Seed Missions
        Mission::firstOrCreate(
            ['title' => 'Penyelamat Pertama'],
            [
                'description' => 'Selamatkan 1 spesies hewan di Baloga',
                'type' => 'daily',
                'target_count' => 1,
                'xp_reward' => 100,
                'icon_url' => 'assets/missions/daily1.png',
            ]
        );

        Mission::firstOrCreate(
            ['title' => 'Pencinta Flora Baloga'],
            [
                'description' => 'Temukan 3 tumbuhan langka',
                'type' => 'daily',
                'target_count' => 3,
                'xp_reward' => 250,
                'icon_url' => 'assets/missions/daily2.png',
            ]
        );

        Mission::firstOrCreate(
            ['title' => 'Master Ekosistem'],
            [
                'description' => 'Selamatkan 10 spesies berbeda di Baloga',
                'type' => 'weekly',
                'target_count' => 10,
                'xp_reward' => 1000,
                'icon_url' => 'assets/missions/weekly1.png',
            ]
        );

        // 5. Seed Badges
        Badge::firstOrCreate(
            ['name' => 'Penyelamat Muda'],
            [
                'description' => 'Menangkap spesies pertama di Baloga',
                'icon_url' => 'assets/badges/badge_first.png',
                'requirement_type' => 'species_count',
                'requirement_value' => 1,
            ]
        );

        Badge::firstOrCreate(
            ['name' => 'Pelindung Satwa'],
            [
                'description' => 'Menangkap 5 spesies hewan',
                'icon_url' => 'assets/badges/badge_animals.png',
                'requirement_type' => 'animals_count',
                'requirement_value' => 5,
            ]
        );

        Badge::firstOrCreate(
            ['name' => 'Botanis Baloga'],
            [
                'description' => 'Menangkap 5 spesies tumbuhan',
                'icon_url' => 'assets/badges/badge_plants.png',
                'requirement_type' => 'plants_count',
                'requirement_value' => 5,
            ]
        );

        // 6. Seed Demo User
        $user = User::firstOrCreate(
            ['email' => 'ranger@baloga.com'],
            [
                'name' => 'Ranger Baloga',
                'password' => Hash::make('password123'),
                'avatar_url' => 'https://api.dicebear.com/7.x/bottts/svg?seed=Ranger',
                'level' => 3,
                'xp' => 450,
                'points' => 1250,
                'species_found' => 2,
                'badges_count' => 1,
            ]
        );

        // Give User initial Eko-Spheres & Items
        $ballItem = Item::where('type', 'capture_ball')->first();
        if ($ballItem) {
            UserItem::firstOrCreate(
                ['user_id' => $user->id, 'item_id' => $ballItem->id],
                ['quantity' => 20]
            );
        }

        // 7. Seed Admin User
        User::firstOrCreate(
            ['email' => 'admin@baloga.com'],
            [
                'name' => 'Admin Baloga',
                'password' => Hash::make('admin123'),
                'avatar_url' => 'https://api.dicebear.com/7.x/bottts/svg?seed=Admin',
                'level' => 99,
                'xp' => 9999,
                'points' => 99999,
                'species_found' => 8,
                'badges_count' => 3,
                'is_admin' => true,
            ]
        );

        // 8. Seed Default App Settings
        AppSetting::set('app_name', 'Baloga AR Rescue');
        AppSetting::set('app_tagline', 'Penjaga Ekosistem Baloga');
        AppSetting::set('app_logo_url', asset('storage/app/logo/rmi_logo.png'));
        AppSetting::set('api_domain', 'https://balago.rozitech.co.id');
    }
}
