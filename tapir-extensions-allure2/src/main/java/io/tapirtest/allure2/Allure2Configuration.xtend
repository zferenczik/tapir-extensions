package io.tapirtest.allure2;

import de.bmiag.tapir.bootstrap.annotation.ModuleConfiguration
import org.springframework.boot.autoconfigure.AutoConfigureOrder

/** 
 * Provides the configuration for the tapir extensions Allure 2 module. In this configuration class only beans are registered which are not annotated by Component.
 * 
 * @author Oliver Libutzki {@literal <}oliver.libutzki@libutzki.de{@literal >}
 * 
 * @since 1.0.0
 */
@ModuleConfiguration
@AutoConfigureOrder(Allure2Configuration.AUTO_CONFIGURE_ORDER)
class Allure2Configuration {

	public static final int AUTO_CONFIGURE_ORDER = 7000
	
}
