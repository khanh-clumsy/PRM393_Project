(function () {
    const originalFetch = window.fetch;
    window.fetch = async function (...args) {
        const response = await originalFetch(...args);
        
        const url = args[0];
        if (typeof url === 'string' && url.includes('/api/auth/login') && response.status === 200) {
            try {
                const clone = response.clone();
                const data = await clone.json();
                
                const token = data.accessToken || data.token;
                if (token) {
                    const ui = window.ui;
                    if (ui && ui.authActions) {
                        ui.authActions.authorize({
                            Bearer: {
                                name: "Bearer",
                                schema: {
                                    type: "apiKey",
                                    in: "header",
                                    name: "Authorization",
                                    description: "JWT Authorization header"
                                },
                                value: "Bearer " + token
                            }
                        });
                        console.log("Swagger authorization token auto-injected successfully.");
                    } else {
                        console.warn("Swagger window.ui or ui.authActions is not available.");
                    }
                }
            } catch (err) {
                console.error("Failed to auto-authorize: ", err);
            }
        }
        return response;
    };
})();
