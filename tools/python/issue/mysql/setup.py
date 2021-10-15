import setuptools

readme = 'README.md'

setuptools.setup(
   name='pool',
   version='0.0.1',
   author='simahao',
   py_modules=['pool'],
   license='MIT',
   python_requires='>=3.4',
   install_requires=['pymysql>=1.0.2'],
   keywords=[
      'pymysql pool',
      'mysql connection pool'
   ],
   packages=setuptools.find_packages()
)
