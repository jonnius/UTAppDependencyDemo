#ifndef MYOPENCVPLUGIN_H
#define MYOPENCVPLUGIN_H

#include <QObject>

class Myopencvplugin: public QObject {
    Q_OBJECT

public:
    Myopencvplugin();
    ~Myopencvplugin() = default;

    Q_INVOKABLE void speak();
};

#endif
