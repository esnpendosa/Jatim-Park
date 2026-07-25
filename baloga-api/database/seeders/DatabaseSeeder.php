<?php

namespace Database\Seeders;

use App\Models\Badge;
use App\Models\GameLocation;
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
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Seed Game Location (Batu Love Garden / Baloga)
        $location = GameLocation::create([
            'name' => 'Batu Love Garden (Baloga)',
            'latitude' => -7.892543,
            'longitude' => 112.548972,
            'radius_meters' => 1000,
        ]);

        // 2. Seed Species (Baloga Animals & Plants)
        $speciesData = [
            [
                'name' => 'Harimau Sumatra',
                'latin_name' => 'Panthera tigris sumatrae',
                'category' => 'hewan',
                'rarity' => 'legendary',
                'habitat' => 'Hutan Hujan Tropis Sumatra',
                'food' => 'Karnivora (Rusa, Babi Hutan)',
                'ecological_role' => 'Predator puncak penyortir keseimbangan populasi herbivora',
                'conservation_status' => 'Kritis (Critically Endangered)',
                'fun_fact' => 'Harimau Sumatra adalah subspesies harimau terkecil yang masih hidup.',
                'base_cp' => 1500,
                'thumbnail_url' => 'https://images.unsplash.com/photo-1561731216-c3a4d99437d5?w=500',
            ],
            [
                'name' => 'Orangutan Kalimantan',
                'latin_name' => 'Pongo pygmaeus',
                'category' => 'hewan',
                'rarity' => 'epic',
                'habitat' => 'Hutan Dataran Rendah Kalimantan',
                'food' => 'Buah-buahan, Daun, Kulit Kayu',
                'ecological_role' => 'Penyebar benih utama di hutan dataran rendah',
                'conservation_status' => 'Kritis (Critically Endangered)',
                'fun_fact' => 'Orangutan memiliki 97% DNA yang mirip dengan manusia.',
                'base_cp' => 1200,
                'thumbnail_url' => 'https://images.unsplash.com/photo-1540573133985-778788170485?w=500',
            ],
            [
                'name' => 'Burung Jalak Bali',
                'latin_name' => 'Leucopsar rothschildi',
                'category' => 'hewan',
                'rarity' => 'rare',
                'habitat' => 'Hutan Musim Bagian Barat Bali',
                'food' => 'Biji-bijian, Serangga, Buah Kecil',
                'ecological_role' => 'Pengendali hama serangga dan penyerbuk',
                'conservation_status' => 'Terancam Punah (Endangered)',
                'fun_fact' => 'Burung endemik Bali ini memiliki bulu putih bersih dengan lingkaran biru di mata.',
                'base_cp' => 800,
                'thumbnail_url' => 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?w=500',
            ],
            [
                'name' => 'Kupu-Kupu Sayap Burung',
                'latin_name' => 'Ornithoptera priamus',
                'category' => 'hewan',
                'rarity' => 'common',
                'habitat' => 'Taman Bunga Baloga',
                'food' => 'Nektar Bunga',
                'ecological_role' => 'Penyerbuk utama tanaman berbunga',
                'conservation_status' => 'Risiko Rendah (Least Concern)',
                'fun_fact' => 'Memiliki rentang sayap yang sangat lebar hingga 20 cm.',
                'base_cp' => 350,
                'thumbnail_url' => 'https://images.unsplash.com/photo-1526336024174-e58f5cdd8e13?w=500',
            ],
            [
                'name' => 'Bunga Rafflesia Arnoldii',
                'latin_name' => 'Rafflesia arnoldii',
                'category' => 'tumbuhan',
                'rarity' => 'legendary',
                'habitat' => 'Hutan Hujan Sumatra & Jawa',
                'food' => 'Parasit Obligat',
                'ecological_role' => 'Indikator keanekaragaman hayati hutan primer',
                'conservation_status' => 'Rentan (Vulnerable)',
                'fun_fact' => 'Merupakan bunga tunggal terbesar di dunia dengan diameter mencapai 1 meter.',
                'base_cp' => 1600,
                'thumbnail_url' => 'https://images.unsplash.com/photo-1534067783941-51c9c23ecefd?w=500',
            ],
            [
                'name' => 'Anggrek Hitam Papua',
                'latin_name' => 'Coelogyne pandurata',
                'category' => 'tumbuhan',
                'rarity' => 'epic',
                'habitat' => 'Hutan Tropis Lembab',
                'food' => 'Fotosintesis / Epifit',
                'ecological_role' => 'Menyediakan mikro-ekosistem bagi serangga penyerbuk',
                'conservation_status' => 'Langka (Rare)',
                'fun_fact' => 'Memiliki lidah bunga (labellum) berwarna hitam pekat yang eksotis.',
                'base_cp' => 1100,
                'thumbnail_url' => 'https://images.unsplash.com/photo-1525310072745-f49212b5ac6d?w=500',
            ],
            [
                'name' => 'Kantong Semar',
                'latin_name' => 'Nepenthes raja',
                'category' => 'tumbuhan',
                'rarity' => 'rare',
                'habitat' => 'Pegunungan Lembab',
                'food' => 'Karnivora (Serangga, Kecoa)',
                'ecological_role' => 'Pengendali populasi serangga air & darat',
                'conservation_status' => 'Terancam (Endangered)',
                'fun_fact' => 'Perangkap kantongnya dapat menampung hingga 2 liter cairan!',
                'base_cp' => 750,
                'thumbnail_url' => 'https://images.unsplash.com/photo-1508615070457-7baeba4003ab?w=500',
            ],
            [
                'name' => 'Bunga Edelweis Jawa',
                'latin_name' => 'Anaphalis javanica',
                'category' => 'tumbuhan',
                'rarity' => 'common',
                'habitat' => 'Zona Alpina Pegunungan Jawa',
                'food' => 'Fotosintesis',
                'ecological_role' => 'Tumbuhan pelopor penyubur tanah vulkanik',
                'conservation_status' => 'Dilindungi (Protected)',
                'fun_fact' => 'Dikenal sebagai Bunga Abadi karena hormon etilennya mampu mencegah kerontokan kelopak.',
                'base_cp' => 400,
                'thumbnail_url' => 'https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07?w=500',
            ],
        ];

        foreach ($speciesData as $data) {
            $s = Species::create($data);

            // Seed Spawn Points nearby Baloga
            // Offsets around -7.892543, 112.548972
            $latOffset = (mt_rand(-50, 50) / 10000);
            $lngOffset = (mt_rand(-50, 50) / 10000);

            SpawnPoint::create([
                'species_id' => $s->id,
                'latitude' => -7.892543 + $latOffset,
                'longitude' => 112.548972 + $lngOffset,
                'active' => true,
                'respawn_minutes' => 15,
            ]);
        }

        // 3. Seed Items
        $items = [
            [
                'name' => 'Eko-Sphere Standard',
                'description' => 'Bola penangkap standar untuk menyelamatkan spesies hewan & tumbuhan.',
                'type' => 'capture_ball',
                'icon_url' => 'assets/items/ekosphere_std.png',
            ],
            [
                'name' => 'Eko-Sphere Great',
                'description' => 'Bola penangkap canggih dengan tingkat keberhasilan lebih tinggi.',
                'type' => 'capture_ball',
                'icon_url' => 'assets/items/ekosphere_great.png',
            ],
            [
                'name' => 'Eco Scanner',
                'description' => 'Alat pemindai informasi ekologis spesies dari jarak jauh.',
                'type' => 'scanner',
                'icon_url' => 'assets/items/eco_scanner.png',
            ],
            [
                'name' => 'Nature Radar',
                'description' => 'Memperluas jangkauan deteksi monster di sekitar peta Baloga.',
                'type' => 'radar',
                'icon_url' => 'assets/items/nature_radar.png',
            ],
            [
                'name' => 'Lucky Leaf',
                'description' => 'Meningkatkan XP & poin dari penangkapan spesies selama 30 menit.',
                'type' => 'booster',
                'icon_url' => 'assets/items/lucky_leaf.png',
            ],
        ];

        foreach ($items as $itemData) {
            Item::create($itemData);
        }

        // 4. Seed Missions
        Mission::create([
            'title' => 'Penyelamat Pertama',
            'description' => 'Selamatkan 1 spesies hewan di Baloga',
            'type' => 'daily',
            'target_count' => 1,
            'xp_reward' => 100,
            'icon_url' => 'assets/missions/daily1.png',
        ]);

        Mission::create([
            'title' => 'Pencinta Flora Baloga',
            'description' => 'Temukan 3 tumbuhan langka',
            'type' => 'daily',
            'target_count' => 3,
            'xp_reward' => 250,
            'icon_url' => 'assets/missions/daily2.png',
        ]);

        Mission::create([
            'title' => 'Master Ekosistem',
            'description' => 'Selamatkan 10 spesies berbeda di Baloga',
            'type' => 'weekly',
            'target_count' => 10,
            'xp_reward' => 1000,
            'icon_url' => 'assets/missions/weekly1.png',
        ]);

        // 5. Seed Badges
        Badge::create([
            'name' => 'Penyelamat Muda',
            'description' => 'Menangkap spesies pertama di Baloga',
            'icon_url' => 'assets/badges/badge_first.png',
            'requirement_type' => 'species_count',
            'requirement_value' => 1,
        ]);

        Badge::create([
            'name' => 'Pelindung Satwa',
            'description' => 'Menangkap 5 spesies hewan',
            'icon_url' => 'assets/badges/badge_animals.png',
            'requirement_type' => 'animals_count',
            'requirement_value' => 5,
        ]);

        Badge::create([
            'name' => 'Botanis Baloga',
            'description' => 'Menangkap 5 spesies tumbuhan',
            'icon_url' => 'assets/badges/badge_plants.png',
            'requirement_type' => 'plants_count',
            'requirement_value' => 5,
        ]);

        // 6. Seed Demo User
        $user = User::create([
            'name' => 'Ranger Baloga',
            'email' => 'ranger@baloga.com',
            'password' => Hash::make('password123'),
            'avatar_url' => 'https://api.dicebear.com/7.x/bottts/svg?seed=Ranger',
            'level' => 3,
            'xp' => 450,
            'points' => 1250,
            'species_found' => 2,
            'badges_count' => 1,
        ]);

        // Give User initial Eko-Spheres & Items
        $ballItem = Item::where('type', 'capture_ball')->first();
        if ($ballItem) {
            UserItem::create([
                'user_id' => $user->id,
                'item_id' => $ballItem->id,
                'quantity' => 20,
            ]);
        }
    }
}
