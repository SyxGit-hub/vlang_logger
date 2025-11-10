module core

import time
import os

pub enum LogLevel {
	debug
	info
	warn
	error
}


pub struct Logger {
pub:
	name string
pub mut:
	level LogLevel
	logger_buffer []string
	logger_path string
}

pub fn append_file(path string, content string) {
    mut f := os.open_file(path, 'a') or {
        panic('Fehler beim Öffnen der Datei: $err')
    }
    defer {
        f.close()
    }

    f.write_string(content) or {
        panic('Fehler beim Schreiben in die Datei: $err')
    }
}

pub fn new(name string, level LogLevel) Logger {
	return Logger{
		name: name
		level: level
		logger_buffer: []string{len: 1}
	}
	
}

pub fn exit_logger(logger Logger) {
	if logger.logger_buffer.len > 0 {
		append_file(logger.logger_path, logger.logger_buffer.join(''))
	}
}

fn create_logger_path(logger Logger) string {
	work_dir := os.getwd()
	logger_path := work_dir + '/' + logger.name + '.log'
	return logger_path
}

fn create_log_file_if_not_exist(path string) {
	if os.exists(path) {
		println(path)
		os.create(path)or {
        	panic('Konnte Datei nicht erstellen: $err')
    	}
	}
}

fn match_log_level(level LogLevel) string {
	level_str := match level {
		.debug { 'DEBUG' }
		.info  { 'INFO' }
		.warn  { 'WARN' }
		.error { 'ERROR' }
	}
	return level_str
}

pub fn (mut logger Logger) log(level LogLevel, message string) {
	if int(level) < int(logger.level) {
		return
	}
	timestamp := time.now().str() // simple Zeit als String
	level_str := match_log_level(level)
	println('[$timestamp] [$level_str] [$logger.name] $message')
	logger.logger_buffer << '[$timestamp] [$level_str] [$logger.name] $message\n'
	logger_path := create_logger_path(logger)
	logger.logger_path = logger_path
	create_log_file_if_not_exist(logger_path)
	if logger.logger_buffer.len >= 999 {
		append_file(logger_path, logger.logger_buffer.join(''))
		logger.logger_buffer.clear()
	}
}

// ----------------------------
// Shortcuts
pub fn (mut l Logger) debug(msg string) { l.log(.debug, msg) }
pub fn (mut l Logger) info(msg string)  { l.log(.info, msg) }
pub fn (mut l Logger) warn(msg string)  { l.log(.warn, msg) }
pub fn (mut l Logger) error(msg string) { l.log(.error, msg) }
