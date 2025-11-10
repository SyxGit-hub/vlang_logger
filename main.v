import core

fn main() {

	mut log := core.new('main', .debug)

	
    defer {
		core.exit_logger(log)
    }

	log.debug('This is a debug message')
	log.info('This is an info message')
	log.warn('Watch out!')
	log.error('Something went wrong!')
}
