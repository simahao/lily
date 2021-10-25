import setuptools

readme = 'README.md'

setuptools.setup(
   name='issuebot',
   version='0.0.1',
   author='simahao',
   py_modules=['issuebot'],
   license='MIT',
   python_requires='>=3.8',
   install_requires=['pymysql>=1.0.2','pool>=0.0.1'],
   keywords=[
      'A bot can get ST issue and push to gitea server automatically'
   ],
   packages=setuptools.find_packages()
)
