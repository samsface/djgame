#ifndef GDEXAMPLE_H
#define GDEXAMPLE_H

#include <godot_cpp/classes/audio_stream_player.hpp>
#include <memory>
#include "z_libpd.h"
#include "z_queued.h"
#include "z_print_util.h"

namespace godot {

class GDExample : public AudioStreamPlayer {
	GDCLASS(GDExample, AudioStreamPlayer)

private:
	double time_passed;
	float inbuf_[1];
	float outbuf_[44100 * 2];
	float initialized_{};
	void* opened_patch_{};
	bool message_guard_{};

protected:
	static void _bind_methods();

public:
	GDExample();
	~GDExample();

	void _process(double delta) override;

	bool is_initialized() const;
	bool open_patch(String patch_path);
	bool send_bang(String receiver);
	bool send_float(String receiver, float value);
	bool start_message(int max_length);
	void add_float(float value);
	void add_symbol(String value);
	bool finish_list(String receiver);
	bool finish_message(String receiver, String message);
	void bind(String receiver);
	bool start_gui(String pure_data_bin_dir_path);
};

}

#endif
