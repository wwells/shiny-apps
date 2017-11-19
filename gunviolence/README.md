# Gun Violence Shiny App

Deployed at:  http://gunviolence.waltwells.com/

## Docker

### Option 1:  Use Container in Quay

Pull from Quay

```
docker pull quay.io/wwells/gunviolence
```

Run application

```
sudo docker run --rm  -p 80:80 --name gunviolence quay.io/wwells/gunviolence
```

### Option 2:  Roll your own

Mod app as desired and build

```
docker build -t gunviolence .
```

```
sudo docker run --rm  -p 80:80 --name gunviolence gunviolence
```

