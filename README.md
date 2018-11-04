# Cross compiling an external dependency

This document demonstrates a way to cross compile an external dependency of your Ubuntu Touch app with an easy build script. This requires the
dependency to provide a CMake configuration. The build script allows
to cross compile for *armhf*, *amd* or to simply compile
the dependency for your host machine in a way that you
only need to compile it once for each architecture.

## Git Submodule
Add the dependency repo as a submodule:

```
git submodule add <URL> libs/<dependency>
git add .gitmodules
git commit -m "Add <dependency> as a submodule"
```

For example:
```
git submodule add git@github.com:opencv/opencv.git libs/opencv
git add .gitmodules
git commit -m "Add OpenCV as a submodule"
```

## Dependency Build Script
Add the **build-dependency.sh** template to your repo. Edit the
configuration section at the beginning of the file. Set the name
of your dependency with `DEPENDENCY`. If needed, set additional
arguments that need to be passed to CMake with `BUILD_ARGS`.
You may also increase the number of build jobs with `JOBS`, risking a high
memory consumption during the build. The configuration section
looks like this:


```
########################
## Configuration - Start

# The name of the dependency, as you named the git submodule.
# Example: If you git submodule is located under /lib/opencv,
# you need to set DEPENDENCY=opencv
DEPENDENCY=dependency

# Number of parallel make jobs. Be carefull, increasing this
# number may lead to massive swapping on machines with low RAM!
JOBS="1"

# Build arguments
BUILD_ARGS="-DCMAKE_BUILD_TYPE=Release"
# Add arguments as needed. For example, if you want to
# set BUILD_TESTS to "ON", add:
# BUILD_ARGS="$BUILD_ARGS -DBUILD_TESTS=ON"
# BUILD_ARGS="$BUILD_ARGS -DBUILD_DOCS=OFF"

## Configuration  -  End
########################
```

Test your build script:

```
./build-dependency.sh
```

At first run it will download the dependency
source code by cloning the submodule. This may take a while. The build directory is located at **build/<dependency\>/<architecture\>** (e.g. **build/opencv/arm-linux-gnueabihf**).

## Include and link the dependency
Many libraries provide a CMake config file that allow to easily
include and link the library by using
[find_package](https://cmake.org/cmake/help/latest/command/find_package.html).
Such a file is either named `<PackageName>Config.cmake` or
`<lower-case-package-name>-config.cmake` (e.g. **OpenCVConfig.cmake**) and can be found in the
build directory.

If your project has been created with `clickable create` (*cmake - C++/QML App*), your CMakeLists.txt already contains the
following lines to set the variable `ARCH_TRIPLET` with
the architecture we are building for. If not, add them:

```
# Get Architecture triplet
execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
```

Make sure the variable `ARCH_TRIPLET` is set before the lines
we add now.
In your C++ plugin, add the following lines to your **CMakeLists.txt**
to let CMake find the dependency:

```
set(<PackageName>_DIR "${CMAKE_BINARY_DIR}/../<dependency>/${ARCH_TRIPLET}")
find_package(<PackageName> REQUIRED)
```

Let CMake include the directories containing the library headers:

```
include_directories(${<PackageName>_INCLUDE_DIRS})
```

And finally link your plugin against the library:

```
target_link_libraries(${PLUGIN} ${<PackageName>_LIBS})
```
The variables `<PackageName>_INCLUDE_DIRS` and `<PackageName>_LIBS`
are provided by the previously mentioned CMake configuration in the
dependency's build dir and their names may vary.

## Clickable.json
The **build-dependency.sh** script builds the dependency in **build/<dependency\>/<architecture\>**. By default [clickable](http://clickable.bhdouglass.com/en/latest/)
 uses **build** as the build directory for the app.
 Therefore, a `clickable clean` would
wipe the build of our dependency. To avoid this and keep the build
directories separated we should set
a custom build directory for our app. Add the following line to
your **clickable.json**:

```
"dir": "build/<appname>"
```

## Example
See the [example](https://github.com/jonnius/UTAppDependencyDemo/tree/master/example) demonstrating how to add some OpenCV Modules as dependencies. It has been create with `clickable create` and the following commits following this README:

 - [Add OpenCV as a submodule](https://github.com/jonnius/UTAppDependencyDemo/commit/3664269e6b71bef22458396b448e4b9593e96a4e)
 - [Add build-dependency.sh](https://github.com/jonnius/UTAppDependencyDemo/commit/7eeeef0b802153b65bdd6f3f28e0227b9ada0bc2#diff-1a79a4d60de6718e8e5b326e338ae533)
 - [Edit build script](https://github.com/jonnius/UTAppDependencyDemo/commit/ac9b9fbbf03fa5b81407f0ef4da6eb5108789c69#diff-1a79a4d60de6718e8e5b326e338ae533)
 - [Include and link the dependency](https://github.com/jonnius/UTAppDependencyDemo/commit/1a62f4930bb4bfb3944b5113d50852f97e76822f#diff-1a79a4d60de6718e8e5b326e338ae533)
 - [Set custom build dir in clickable.json](https://github.com/jonnius/UTAppDependencyDemo/commit/0d1eca4789cd752d4f0c5c427c8637a7d51671ec#diff-1a79a4d60de6718e8e5b326e338ae533)
 

### Building for the device
Building the dependency must be done once:
```
.build-dependency
```
From now on build the App for your desktop
```
clickable
```
 
### Building for desktop
Building the dependency must be done once:
```
.build-dependency host
```
From now on build the App for your desktop
```
clickable desktop
```
