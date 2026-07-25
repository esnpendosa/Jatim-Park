<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 2. species
        Schema::create('species', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('latin_name');
            $table->enum('category', ['hewan', 'tumbuhan']);
            $table->enum('rarity', ['common', 'rare', 'epic', 'legendary']);
            $table->string('habitat');
            $table->string('food')->nullable();
            $table->text('ecological_role');
            $table->string('conservation_status');
            $table->text('fun_fact');
            $table->string('model_3d_url')->nullable();
            $table->string('thumbnail_url')->nullable();
            $table->integer('base_cp')->default(100);
            $table->timestamps();
        });

        // 3. game_locations
        Schema::create('game_locations', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->integer('radius_meters')->default(500);
            $table->timestamps();
        });

        // 4. spawn_points
        Schema::create('spawn_points', function (Blueprint $table) {
            $table->id();
            $table->foreignId('species_id')->constrained('species')->onDelete('cascade');
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->boolean('active')->default(true);
            $table->integer('respawn_minutes')->default(15);
            $table->timestamps();
        });

        // 5. captures
        Schema::create('captures', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('species_id')->constrained('species')->onDelete('cascade');
            $table->timestamp('captured_at')->useCurrent();
            $table->decimal('latitude', 10, 8);
            $table->decimal('longitude', 11, 8);
            $table->integer('cp_result');
            $table->timestamps();
        });

        // 6. inventories
        Schema::create('inventories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('species_id')->constrained('species')->onDelete('cascade');
            $table->integer('quantity')->default(1);
            $table->timestamp('first_captured_at')->useCurrent();
            $table->timestamps();
        });

        // 7. items
        Schema::create('items', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description');
            $table->string('icon_url')->nullable();
            $table->enum('type', ['capture_ball', 'scanner', 'radar', 'booster']);
            $table->timestamps();
        });

        // 8. user_items
        Schema::create('user_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('item_id')->constrained('items')->onDelete('cascade');
            $table->integer('quantity')->default(0);
            $table->timestamps();
        });

        // 9. missions
        Schema::create('missions', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->enum('type', ['daily', 'weekly']);
            $table->integer('target_count');
            $table->integer('xp_reward');
            $table->string('icon_url')->nullable();
            $table->timestamps();
        });

        // 10. user_missions
        Schema::create('user_missions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('mission_id')->constrained('missions')->onDelete('cascade');
            $table->integer('current_progress')->default(0);
            $table->boolean('is_completed')->default(false);
            $table->timestamp('reset_at')->nullable();
            $table->timestamps();
        });

        // 11. badges
        Schema::create('badges', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description');
            $table->string('icon_url')->nullable();
            $table->string('requirement_type');
            $table->integer('requirement_value');
            $table->timestamps();
        });

        // 12. user_badges
        Schema::create('user_badges', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('badge_id')->constrained('badges')->onDelete('cascade');
            $table->timestamp('earned_at')->useCurrent();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('user_badges');
        Schema::dropIfExists('badges');
        Schema::dropIfExists('user_missions');
        Schema::dropIfExists('missions');
        Schema::dropIfExists('user_items');
        Schema::dropIfExists('items');
        Schema::dropIfExists('inventories');
        Schema::dropIfExists('captures');
        Schema::dropIfExists('spawn_points');
        Schema::dropIfExists('game_locations');
        Schema::dropIfExists('species');
    }
};
