# ----------------------------------------------------
# 階段 1: 建構 (Build Stage)
# 改用官方 Maven 鏡像中，保證包含 JDK 17 的最簡潔標籤。
# ----------------------------------------------------
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

# 複製 Maven 專案設定檔 (pom.xml)
COPY pom.xml .

# 先下載依賴，利用 Docker 快取機制加速
RUN mvn dependency:go-offline

# 複製原始碼並執行打包 (會執行 mvn clean package -DskipTests)
COPY src ./src
RUN mvn clean package -DskipTests

# ----------------------------------------------------
# 階段 2: 運行 (Runtime Stage)
# 使用官方 OpenJDK 鏡像，JRE 17 輕量版。
# ----------------------------------------------------
FROM eclipse-temurin:17-jre
WORKDIR /app

# 從建構階段複製最終的 JAR 文件
COPY --from=build /app/target/*.jar app.jar

# 暴露服務端口
EXPOSE 8080

# 定義啟動命令
ENTRYPOINT ["java", "-jar", "app.jar"]