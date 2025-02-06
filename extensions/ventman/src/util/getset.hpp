#define GETTER(type, name, var) \
	type get_##name() const { return var; }

#define SETTER(type, name, var) \
	void set_##name(const type &value) { var = value; }

#define GETSET(type, name, var) \
	GETTER(type, name, var)     \
	SETTER(type, name, var)