#include <QtQml>
#include <QtQml/QQmlContext>

#include "plugin.h"
#include "myopencvplugin.h"

void MyopencvpluginPlugin::registerTypes(const char *uri) {
    //@uri Myopencvplugin
    qmlRegisterSingletonType<Myopencvplugin>(uri, 1, 0, "Myopencvplugin", [](QQmlEngine*, QJSEngine*) -> QObject* { return new Myopencvplugin; });
}
