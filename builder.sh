#!/bin/bash

# ANSI Color Codes for Premium Look
BLUE='\033[1;34m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
WHITE='\033[1;37m'
NC='\033[0m'

# Default Java Version
if [ -z "$CURRENT_JAVA" ]; then
    CURRENT_JAVA="17"
fi

# Function to update environment
update_java_env() {
    case $CURRENT_JAVA in
        "8")  export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64" ;;
        "11") export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64" ;;
        "17") export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64" ;;
        "21") export JAVA_HOME="/opt/java/jdk-21" ;;
        "23") export JAVA_HOME="/opt/java/jdk-23" ;;
        "25") export JAVA_HOME="/opt/java/jdk-25" ;;
        *)    export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64" ;;
    esac
    
    export PATH="$JAVA_HOME/bin:/opt/gradle/gradle-8.5/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
}

draw_line() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

show_header() {
    clear
    draw_line
    echo -e "  ${WHITE}⚡ ${PURPLE}PLUGIN BUILDER ${WHITE}⚡${NC}"
    echo -e "  ${CYAN}Modern Multi-Version Java Build System${NC}"
    draw_line
    echo -e "  ${YELLOW}SYSTEM INFORMATION${NC}"
    echo -e "  ${WHITE}Java Version :${NC} ${GREEN}$CURRENT_JAVA${NC}"
    echo -e "  ${WHITE}Java Home    :${NC} ${BLUE}$JAVA_HOME${NC}"
    
    # Check Java availability
    if [ -d "$JAVA_HOME" ]; then
        JAVA_DETAIL=$(java -version 2>&1 | head -n 1)
        echo -e "  ${WHITE}Detail       :${NC} $JAVA_DETAIL"
        echo -e "  ${WHITE}Status       :${NC} ${GREEN}● READY${NC}"
    else
        echo -e "  ${WHITE}Status       :${NC} ${RED}● JAVA NOT FOUND${NC}"
    fi
    draw_line
    echo ""
}

change_java() {
    show_header
    echo -e "  ${YELLOW}AVAILABLE JAVA VERSIONS${NC}"
    echo -e "  ${CYAN}1.${NC} Java 8   (Legacy)"
    echo -e "  ${CYAN}2.${NC} Java 11  (LTS)"
    echo -e "  ${CYAN}3.${NC} Java 17  (LTS - Recommended)"
    echo -e "  ${CYAN}4.${NC} Java 21  (LTS)"
    echo -e "  ${CYAN}5.${NC} Java 23  (Latest)"
    echo -e "  ${CYAN}6.${NC} Java 25  (Future Early Access)"
    echo -e "  ${CYAN}7.${NC} Back to Menu"
    echo ""
    read -p "  Select Version [1-7]: " j_opt
    
    case $j_opt in
        1) CURRENT_JAVA="8" ;;
        2) CURRENT_JAVA="11" ;;
        3) CURRENT_JAVA="17" ;;
        4) CURRENT_JAVA="21" ;;
        5) CURRENT_JAVA="23" ;;
        6) CURRENT_JAVA="25" ;;
        7) return ;;
        *) echo -e "  ${RED}Invalid Option!${NC}"; sleep 1; return ;;
    esac
    
    update_java_env
    echo -e "  ${GREEN}Switching to Java $CURRENT_JAVA...${NC}"
    sleep 1
}

build_plugin() {
    show_header()
    echo -e "  ${YELLOW}INITIATING BUILD PROCESS...${NC}"
    
    # Ensure folder structure
    mkdir -p /home/container/files/file
    mkdir -p /home/container/files/hasil
    mkdir -p /home/container/logs
    
    # Locate Zip
    ZIP_FILE=$(ls /home/container/files/file/*.zip 2>/dev/null | head -n 1)
    
    if [ -z "$ZIP_FILE" ]; then
        echo -e "  ${RED}✖ ERROR: No source .zip found in files/file/${NC}"
        echo -e "  ${WHITE}Please upload your project as a .zip file to /files/file/${NC}"
        echo ""
        read -p "  Press Enter to return..."
        return
    fi
    
    ZIP_NAME=$(basename "$ZIP_FILE" .zip)
    echo -e "  ${CYAN}📦 Found:${NC} $ZIP_NAME.zip"
    
    # Preparation
    echo -e "  ${CYAN}🧹 Cleaning temporary workspace...${NC}"
    rm -rf /home/container/tmp_build
    mkdir -p /home/container/tmp_build
    
    echo -e "  ${CYAN}📂 Extracting source...${NC}"
    unzip -q "$ZIP_FILE" -d /home/container/tmp_build
    
    cd /home/container/tmp_build || return
    
    # Auto-nesting detection
    if [ $(ls -1 | wc -l) -eq 1 ] && [ -d "$(ls -1)" ]; then
        cd "$(ls -1)" || return
    fi
    
    # Try to detect project name for log file
    PROJECT_NAME="$ZIP_NAME"
    if [ -f "pom.xml" ]; then
        DETECTED_NAME=$(grep -oPm1 "(?<=<artifactId>)[^<]+" pom.xml)
        [ ! -z "$DETECTED_NAME" ] && PROJECT_NAME="$DETECTED_NAME"
    elif [ -f "settings.gradle" ]; then
        DETECTED_NAME=$(grep "rootProject.name" settings.gradle | cut -d"'" -f2 | cut -d'"' -f2)
        [ ! -z "$DETECTED_NAME" ] && PROJECT_NAME="$DETECTED_NAME"
    fi
    
    LOG_FILE="/home/container/logs/${PROJECT_NAME}.log"
    echo -e "  ${CYAN}📝 Log File:${NC} /logs/${PROJECT_NAME}.log"
    
    # Build Logic
    if [ -f "pom.xml" ]; then
        echo -e "  ${CYAN}🛠  Detected:${NC} ${PURPLE}MAVEN PROJECT${NC}"
        draw_line
        echo -e "  ${YELLOW}Building... (Check logs for details)${NC}"
        mvn clean package > "$LOG_FILE" 2>&1
        BUILD_STATUS=$?
        RESULT_DIR="target"
    elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        echo -e "  ${CYAN}🛠  Detected:${NC} ${PURPLE}GRADLE PROJECT${NC}"
        draw_line
        echo -e "  ${YELLOW}Building... (Check logs for details)${NC}"
        if [ -f "./gradlew" ]; then
            chmod +x gradlew
            ./gradlew build > "$LOG_FILE" 2>&1
        else
            gradle build > "$LOG_FILE" 2>&1
        fi
        BUILD_STATUS=$?
        RESULT_DIR="build/libs"
    else
        echo -e "  ${RED}✖ ERROR: Build system not detected (pom.xml or build.gradle missing)${NC}"
        read -p "  Press Enter to return..."
        return
    fi
    
    draw_line
    if [ $BUILD_STATUS -eq 0 ]; then
        echo -e "  ${GREEN}✔ BUILD SUCCESSFUL${NC}"
        
        # Finding the artifact
        FINAL_JAR=$(find "$RESULT_DIR" -maxdepth 1 -name "*.jar" ! -name "*-sources.jar" ! -name "*-javadoc.jar" ! -name "*-all.jar" | sort -r | head -n 1)
        
        if [ -z "$FINAL_JAR" ]; then
             FINAL_JAR=$(find "$RESULT_DIR" -name "*.jar" | head -n 1)
        fi
        
        if [ ! -z "$FINAL_JAR" ]; then
            DEST="/home/container/files/hasil/$(basename "$FINAL_JAR")"
            cp "$FINAL_JAR" "$DEST"
            echo -e "  ${CYAN}💾 Saved to:${NC} $DEST"
        else
            echo -e "  ${YELLOW}⚠ WARNING: Build succeeded but no .jar was found in $RESULT_DIR${NC}"
        fi
    else
        echo -e "  ${RED}✖ BUILD FAILED${NC}"
        echo -e "  ${RED}Please check the log for errors:${NC}"
        echo -e "  ${WHITE}$LOG_FILE${NC}"
        # Show last 10 lines of log for quick debugging
        echo -e "\n  ${YELLOW}Last 10 lines of log:${NC}"
        tail -n 10 "$LOG_FILE" | sed 's/^/  /'
    fi
    
    echo ""
    read -p "  Press Enter to return to menu..."
}

# Initial execution
update_java_env
mkdir -p /home/container/files/file
mkdir -p /home/container/files/hasil
mkdir -p /home/container/logs

while true; do
    show_header
    echo -e "  ${CYAN}1.${NC} ${WHITE}Ubah Java Version${NC}"
    echo -e "  ${CYAN}2.${NC} ${WHITE}Build Plugin (Auto-Detect)${NC}"
    echo -e "  ${CYAN}3.${NC} ${WHITE}Exit${NC}"
    echo ""
    read -p "  Option Selection > " opt
    
    case $opt in
        1) change_java ;;
        2) build_plugin ;;
        3) echo -e "  ${CYAN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "  ${RED}Invalid Selection!${NC}"; sleep 1 ;;
    esac
done
