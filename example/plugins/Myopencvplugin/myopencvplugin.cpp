#include <QDebug>

#include "myopencvplugin.h"

Myopencvplugin::Myopencvplugin() {

}

void Myopencvplugin::speak() {
    qDebug() << "hello world!";
}
